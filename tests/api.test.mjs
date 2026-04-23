#!/usr/bin/env node
/**
 * tests/api.test.mjs
 * Node.js integration tests for Quick Poll API using the built-in node:test runner.
 * Requires Node >= 18 and a running server.
 *
 * Usage:
 *   BASE_URL=http://localhost:3001 node --test tests/api.test.mjs
 */

import { test, describe } from 'node:test';
import assert from 'node:assert/strict';

const BASE_URL = process.env.BASE_URL ?? 'http://localhost:3001';

// ── Helpers ───────────────────────────────────────────────────────────────────

async function apiPost(path, body) {
  const res = await fetch(`${BASE_URL}${path}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const json = await res.json().catch(() => null);
  return { status: res.status, headers: res.headers, body: json };
}

async function apiGet(path) {
  const res = await fetch(`${BASE_URL}${path}`);
  const json = await res.json().catch(() => null);
  return { status: res.status, headers: res.headers, body: json };
}

async function createPoll(question = 'Test question?', options = ['Option A', 'Option B']) {
  const { status, body } = await apiPost('/api/polls', { question, options });
  assert.equal(status, 201, `createPoll failed with ${status}: ${JSON.stringify(body)}`);
  return body;
}

async function castVote(pollId, optionIndex) {
  const { status, body } = await apiPost(`/api/polls/${pollId}/vote`, { optionIndex });
  assert.equal(status, 200, `castVote failed with ${status}: ${JSON.stringify(body)}`);
  return body;
}

// ── Concurrent vote handling ──────────────────────────────────────────────────

describe('Concurrent vote handling', () => {
  test('all simultaneous votes on the same option are counted', async () => {
    const poll = await createPoll('Concurrent same option?', ['Yes', 'No']);
    const CONCURRENT = 10;

    const results = await Promise.all(
      Array.from({ length: CONCURRENT }, () =>
        apiPost(`/api/polls/${poll.id}/vote`, { optionIndex: 0 })
      )
    );

    const failures = results.filter(r => r.status !== 200);
    assert.equal(failures.length, 0,
      `${failures.length} of ${CONCURRENT} concurrent votes failed`);

    const { body } = await apiGet(`/api/polls/${poll.id}`);
    assert.equal(body.options[0].vote_count, CONCURRENT,
      `Expected ${CONCURRENT} votes on option 0, got ${body.options[0].vote_count}`);
    assert.equal(body.options[1].vote_count, 0, 'Unvoted option should remain at 0');
  });

  test('simultaneous votes on different options are counted independently', async () => {
    const poll = await createPoll('Split concurrent?', ['Left', 'Right']);
    const EACH = 5;

    await Promise.all([
      ...Array.from({ length: EACH }, () =>
        apiPost(`/api/polls/${poll.id}/vote`, { optionIndex: 0 })
      ),
      ...Array.from({ length: EACH }, () =>
        apiPost(`/api/polls/${poll.id}/vote`, { optionIndex: 1 })
      ),
    ]);

    const { body } = await apiGet(`/api/polls/${poll.id}`);
    assert.equal(body.options[0].vote_count, EACH, `Left should have ${EACH} votes`);
    assert.equal(body.options[1].vote_count, EACH, `Right should have ${EACH} votes`);
  });

  test('concurrent poll creation produces distinct IDs', async () => {
    const COUNT = 5;
    const results = await Promise.all(
      Array.from({ length: COUNT }, (_, i) =>
        apiPost('/api/polls', { question: `Concurrent poll ${i}?`, options: ['A', 'B'] })
      )
    );

    const ids = results.map(r => r.body.id);
    const unique = new Set(ids);
    assert.equal(unique.size, COUNT, `Expected ${COUNT} distinct poll IDs, got ${unique.size}`);
    results.forEach(r => assert.equal(r.status, 201, 'Each concurrent create should return 201'));
  });
});

// ── Full workflow integration ─────────────────────────────────────────────────

describe('Full workflow integration', () => {
  test('complete lifecycle: create → fetch → vote → verify results', async () => {
    // Create
    const { status: createStatus, body: poll } = await apiPost('/api/polls', {
      question: 'Best programming language?',
      options: ['JavaScript', 'Python', 'Rust', 'Go'],
    });
    assert.equal(createStatus, 201);
    assert.ok(poll.id, 'Poll must have an id');
    assert.equal(poll.options.length, 4);
    assert.ok(poll.options.every(o => o.vote_count === 0), 'All vote counts start at 0');

    // Fetch (simulate following a shared link)
    const { status: fetchStatus, body: fetched } = await apiGet(`/api/polls/${poll.id}`);
    assert.equal(fetchStatus, 200);
    assert.equal(fetched.id, poll.id);
    assert.equal(fetched.question, poll.question);
    assert.equal(fetched.created_at, poll.created_at);

    // Vote on option 2 (Rust)
    const { status: voteStatus, body: voted } = await apiPost(
      `/api/polls/${poll.id}/vote`,
      { optionIndex: 2 }
    );
    assert.equal(voteStatus, 200);
    assert.equal(voted.options[2].vote_count, 1, 'Voted option should increment to 1');
    const otherVotes = voted.options
      .filter((_, i) => i !== 2)
      .reduce((s, o) => s + o.vote_count, 0);
    assert.equal(otherVotes, 0, 'Non-voted options should remain 0');

    // Re-fetch to verify persistence
    const { body: results } = await apiGet(`/api/polls/${poll.id}`);
    assert.equal(results.options[2].vote_count, 1);
    const total = results.options.reduce((s, o) => s + o.vote_count, 0);
    assert.equal(total, 1, 'Total votes should be 1 after one vote');
  });

  test('multiple sequential voters accumulate correctly', async () => {
    const poll = await createPoll('Favourite season?', ['Spring', 'Summer', 'Autumn', 'Winter']);

    await castVote(poll.id, 0); // Spring
    await castVote(poll.id, 1); // Summer
    await castVote(poll.id, 1); // Summer again
    await castVote(poll.id, 3); // Winter

    const { body } = await apiGet(`/api/polls/${poll.id}`);
    assert.equal(body.options[0].vote_count, 1, 'Spring: 1 vote');
    assert.equal(body.options[1].vote_count, 2, 'Summer: 2 votes');
    assert.equal(body.options[2].vote_count, 0, 'Autumn: 0 votes');
    assert.equal(body.options[3].vote_count, 1, 'Winter: 1 vote');

    const total = body.options.reduce((s, o) => s + o.vote_count, 0);
    assert.equal(total, 4, 'Total should equal number of votes cast');
  });

  test('vote response matches subsequent GET response', async () => {
    const poll = await createPoll('Consistency check?', ['P', 'Q', 'R']);

    const voteResult = await castVote(poll.id, 1);
    const { body: getResult } = await apiGet(`/api/polls/${poll.id}`);

    assert.equal(voteResult.id, getResult.id);
    assert.equal(voteResult.question, getResult.question);
    assert.equal(voteResult.created_at, getResult.created_at);
    assert.equal(voteResult.options.length, getResult.options.length);
    for (let i = 0; i < voteResult.options.length; i++) {
      assert.equal(voteResult.options[i].id, getResult.options[i].id);
      assert.equal(voteResult.options[i].vote_count, getResult.options[i].vote_count);
    }
  });
});

// ── Response schema validation ────────────────────────────────────────────────

describe('Response schema validation', () => {
  test('poll creation response has exact expected structure', async () => {
    const { status, body } = await apiPost('/api/polls', {
      question: 'Schema test?',
      options: ['Option 1', 'Option 2', 'Option 3'],
    });

    assert.equal(status, 201);

    // Top-level field types
    assert.equal(typeof body.id, 'string', 'id should be string');
    assert.equal(typeof body.question, 'string', 'question should be string');
    assert.equal(typeof body.created_at, 'number', 'created_at should be number');
    assert.ok(Array.isArray(body.options), 'options should be an array');
    assert.equal(Object.keys(body).sort().join(','), 'created_at,id,options,question',
      'Response should have exactly 4 top-level keys');

    // Each option structure
    assert.equal(body.options.length, 3);
    for (const opt of body.options) {
      assert.equal(typeof opt.id, 'number', 'option.id should be number');
      assert.equal(opt.poll_id, body.id, 'option.poll_id should equal poll id');
      assert.equal(typeof opt.text, 'string', 'option.text should be string');
      assert.equal(typeof opt.vote_count, 'number', 'option.vote_count should be number');
      assert.equal(opt.vote_count, 0, 'vote_count starts at 0');
      assert.equal(Object.keys(opt).sort().join(','), 'id,poll_id,text,vote_count',
        'Option should have exactly 4 keys');
    }
  });

  test('GET response matches POST creation response', async () => {
    const poll = await createPoll('Round-trip consistency?', ['P', 'Q']);

    const { status, body: fetched } = await apiGet(`/api/polls/${poll.id}`);
    assert.equal(status, 200);

    assert.equal(fetched.id, poll.id);
    assert.equal(fetched.question, poll.question);
    assert.equal(fetched.created_at, poll.created_at);
    assert.equal(fetched.options.length, poll.options.length);
    for (let i = 0; i < poll.options.length; i++) {
      assert.equal(fetched.options[i].id, poll.options[i].id);
      assert.equal(fetched.options[i].poll_id, poll.options[i].poll_id);
      assert.equal(fetched.options[i].text, poll.options[i].text);
    }
  });

  test('vote response maintains complete schema', async () => {
    const poll = await createPoll('Vote schema?', ['X', 'Y', 'Z']);

    const { status, body } = await apiPost(`/api/polls/${poll.id}/vote`, { optionIndex: 1 });
    assert.equal(status, 200);

    assert.equal(body.id, poll.id);
    assert.equal(typeof body.question, 'string');
    assert.equal(typeof body.created_at, 'number');
    assert.ok(Array.isArray(body.options));
    assert.equal(body.options.length, 3);
    assert.equal(body.options[0].vote_count, 0, 'option 0 untouched');
    assert.equal(body.options[1].vote_count, 1, 'option 1 voted');
    assert.equal(body.options[2].vote_count, 0, 'option 2 untouched');
  });

  test('created_at is a plausible Unix second timestamp', async () => {
    const poll = await createPoll('Timestamp test?', ['Now', 'Later']);

    const nowSec = Math.floor(Date.now() / 1000);
    const diff = Math.abs(nowSec - poll.created_at);
    assert.ok(diff <= 60, `created_at ${poll.created_at} is not within 60s of now ${nowSec}`);
    assert.ok(poll.created_at > 1_700_000_000, 'created_at should be post-2023');
    assert.ok(poll.created_at < 4_102_444_800, 'created_at should be pre-2100');
  });

  test('options are returned in ascending id order', async () => {
    const poll = await createPoll('Order test?', ['First', 'Second', 'Third', 'Fourth']);
    for (let i = 0; i < poll.options.length - 1; i++) {
      assert.ok(
        poll.options[i].id < poll.options[i + 1].id,
        `options[${i}].id (${poll.options[i].id}) should be < options[${i + 1}].id (${poll.options[i + 1].id})`
      );
    }
  });

  test('Content-Type is application/json on all API endpoints', async () => {
    const poll = await createPoll('CT test?', ['A', 'B']);

    const responses = await Promise.all([
      fetch(`${BASE_URL}/api/polls`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ question: 'CT?', options: ['X', 'Y'] }),
      }),
      fetch(`${BASE_URL}/api/polls/${poll.id}`),
      fetch(`${BASE_URL}/api/polls/${poll.id}/vote`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ optionIndex: 0 }),
      }),
      fetch(`${BASE_URL}/api/polls/00000000-0000-0000-0000-000000000000`),
    ]);

    for (const res of responses) {
      const ct = res.headers.get('content-type') ?? '';
      assert.ok(ct.includes('application/json'),
        `Expected application/json, got "${ct}" for ${res.url} (${res.status})`);
    }
  });
});

// ── Data isolation between polls ──────────────────────────────────────────────

describe('Data isolation between polls', () => {
  test('votes on one poll never affect other polls', async () => {
    const [poll1, poll2, poll3] = await Promise.all([
      createPoll('Isolation A?', ['A1', 'B1']),
      createPoll('Isolation B?', ['A2', 'B2']),
      createPoll('Isolation C?', ['A3', 'B3']),
    ]);

    // Vote 5x on poll1 option 0
    for (let i = 0; i < 5; i++) await castVote(poll1.id, 0);

    // Vote 2x on poll2 option 1
    await castVote(poll2.id, 1);
    await castVote(poll2.id, 1);

    // Poll3 has no votes at all

    const [{ body: p1 }, { body: p2 }, { body: p3 }] = await Promise.all([
      apiGet(`/api/polls/${poll1.id}`),
      apiGet(`/api/polls/${poll2.id}`),
      apiGet(`/api/polls/${poll3.id}`),
    ]);

    assert.equal(p1.options[0].vote_count, 5, 'poll1 option0 should have 5 votes');
    assert.equal(p1.options[1].vote_count, 0, 'poll1 option1 should be untouched');

    assert.equal(p2.options[0].vote_count, 0, 'poll2 option0 should be untouched');
    assert.equal(p2.options[1].vote_count, 2, 'poll2 option1 should have 2 votes');

    assert.equal(p3.options[0].vote_count, 0, 'poll3 option0 should be untouched');
    assert.equal(p3.options[1].vote_count, 0, 'poll3 option1 should be untouched');
  });

  test('two polls with the same question text get different IDs', async () => {
    const q = 'Duplicate question?';
    const [poll1, poll2] = await Promise.all([
      createPoll(q, ['A', 'B']),
      createPoll(q, ['A', 'B']),
    ]);
    assert.notEqual(poll1.id, poll2.id, 'Duplicate-question polls must have distinct IDs');
  });
});

// ── Input validation ──────────────────────────────────────────────────────────

describe('Input validation', () => {
  test('whitespace-only question variants all return 400', async () => {
    const variants = ['   ', '\t', '\n', '\r\n', '  \t  \n'];
    for (const q of variants) {
      const { status, body } = await apiPost('/api/polls', { question: q, options: ['A', 'B'] });
      assert.equal(status, 400,
        `Expected 400 for whitespace question ${JSON.stringify(q)}, got ${status}: ${JSON.stringify(body)}`);
      assert.equal(typeof body.error, 'string', 'Error response must have error field');
    }
  });

  test('invalid option counts return 400', async () => {
    const cases = [
      { options: ['Only one'], desc: '1 option (below min)' },
      { options: ['A', 'B', 'C', 'D', 'E', 'F', 'G'], desc: '7 options (above max)' },
      { options: [], desc: '0 options (empty array)' },
    ];
    for (const { options, desc } of cases) {
      const { status } = await apiPost('/api/polls', { question: 'Q?', options });
      assert.equal(status, 400, `Expected 400 for ${desc}`);
    }
  });

  test('invalid optionIndex types and values return 400', async () => {
    const poll = await createPoll('Validation?', ['P', 'Q', 'R']);

    const cases = [
      { v: -1,        desc: 'negative integer' },
      { v: 3,         desc: 'out of range (== options.length)' },
      { v: 100,       desc: 'far out of range' },
      { v: 0.5,       desc: 'float' },
      { v: '0',       desc: 'string "0"' },
      { v: null,      desc: 'null' },
      { v: true,      desc: 'boolean true' },
      { v: false,     desc: 'boolean false' },
    ];

    for (const { v, desc } of cases) {
      const { status, body } = await apiPost(`/api/polls/${poll.id}/vote`, { optionIndex: v });
      assert.equal(status, 400,
        `Expected 400 for optionIndex=${desc}, got ${status}: ${JSON.stringify(body)}`);
    }
  });

  test('whitespace is trimmed from question and options before storage', async () => {
    const { body } = await apiPost('/api/polls', {
      question: '  Trim test?  ',
      options: ['  Option A  ', '\tOption B\t'],
    });
    assert.equal(body.question, 'Trim test?', 'Question should be trimmed');
    assert.equal(body.options[0].text, 'Option A', 'Option A should be trimmed');
    assert.equal(body.options[1].text, 'Option B', 'Option B should be trimmed');
  });

  test('extra fields in request body are silently ignored', async () => {
    const { status: s1, body: b1 } = await apiPost('/api/polls', {
      question: 'Extra fields?',
      options: ['A', 'B'],
      extra: 'ignored',
      debug: true,
      meta: { foo: 'bar' },
    });
    assert.equal(s1, 201, 'Extra poll creation fields should be ignored');
    assert.equal(b1.question, 'Extra fields?');

    const { status: s2, body: b2 } = await apiPost(`/api/polls/${b1.id}/vote`, {
      optionIndex: 0,
      userId: 'anon',
      timestamp: 9999,
    });
    assert.equal(s2, 200, 'Extra vote fields should be ignored');
    assert.equal(b2.options[0].vote_count, 1);
  });

  test('unicode and emoji in question and options are stored faithfully', async () => {
    const question = 'Favourite emoji? 🎉';
    const options = ['🎉 Party', '🚀 Rocket', '❤️ Heart'];

    const { status, body } = await apiPost('/api/polls', { question, options });
    assert.equal(status, 201);
    assert.equal(body.question, question, 'Unicode question preserved');
    assert.equal(body.options[0].text, options[0], 'Emoji option 0 preserved');
    assert.equal(body.options[1].text, options[1], 'Emoji option 1 preserved');
    assert.equal(body.options[2].text, options[2], 'Emoji option 2 preserved');
  });

  test('HTML special characters are stored verbatim (API does not escape)', async () => {
    const { status, body } = await apiPost('/api/polls', {
      question: '<b>Bold</b> or plain?',
      options: ['<b>Bold</b>', 'Plain &amp; simple'],
    });
    assert.equal(status, 201);
    assert.equal(body.question, '<b>Bold</b> or plain?', 'HTML in question not escaped');
    assert.equal(body.options[1].text, 'Plain &amp; simple', 'HTML entity not double-escaped');
  });
});

// ── Not found handling ────────────────────────────────────────────────────────

describe('Not found handling', () => {
  test('GET non-existent poll returns 404 with error field', async () => {
    const { status, body } = await apiGet('/api/polls/00000000-0000-0000-0000-000000000000');
    assert.equal(status, 404);
    assert.equal(typeof body.error, 'string', 'error field should be a string');
    assert.ok(body.error.length > 0, 'error message should be non-empty');
  });

  test('vote on non-existent poll returns 404 with error field', async () => {
    const { status, body } = await apiPost(
      '/api/polls/00000000-0000-0000-0000-000000000000/vote',
      { optionIndex: 0 }
    );
    assert.equal(status, 404);
    assert.equal(typeof body.error, 'string');
    assert.ok(body.error.length > 0);
  });

  test('non-UUID-shaped poll IDs return 404', async () => {
    const badIds = ['not-a-uuid', '12345', 'abc', 'undefined', ''];
    for (const id of badIds) {
      if (id === '') continue; // empty path segment is not routed to /:id
      const { status } = await apiGet(`/api/polls/${id}`);
      assert.equal(status, 404, `Expected 404 for poll ID "${id}"`);
    }
  });
});

// ── Vote count accumulation ───────────────────────────────────────────────────

describe('Vote count accumulation', () => {
  test('sequential votes accumulate correctly up to high counts', async () => {
    const poll = await createPoll('Accumulation?', ['Alpha', 'Beta']);
    const VOTES_A = 20;
    const VOTES_B = 10;

    for (let i = 0; i < VOTES_A; i++) await castVote(poll.id, 0);
    for (let i = 0; i < VOTES_B; i++) await castVote(poll.id, 1);

    const { body } = await apiGet(`/api/polls/${poll.id}`);
    assert.equal(body.options[0].vote_count, VOTES_A, `Alpha should have ${VOTES_A} votes`);
    assert.equal(body.options[1].vote_count, VOTES_B, `Beta should have ${VOTES_B} votes`);
    const total = body.options.reduce((s, o) => s + o.vote_count, 0);
    assert.equal(total, VOTES_A + VOTES_B, `Total should be ${VOTES_A + VOTES_B}`);
  });

  test('GET is idempotent — does not modify vote counts', async () => {
    const poll = await createPoll('Idempotent GET?', ['X', 'Y']);
    await castVote(poll.id, 0);

    const reads = await Promise.all([
      apiGet(`/api/polls/${poll.id}`),
      apiGet(`/api/polls/${poll.id}`),
      apiGet(`/api/polls/${poll.id}`),
    ]);

    for (const { body } of reads) {
      assert.equal(body.options[0].vote_count, 1, 'Each GET should return the same count');
      assert.equal(body.options[1].vote_count, 0);
    }
  });

  test('voting on every option exactly once sums to option count', async () => {
    const options = ['W', 'X', 'Y', 'Z'];
    const poll = await createPoll('Full cycle?', options);

    for (let i = 0; i < options.length; i++) await castVote(poll.id, i);

    const { body } = await apiGet(`/api/polls/${poll.id}`);
    const total = body.options.reduce((s, o) => s + o.vote_count, 0);
    assert.equal(total, options.length, `Total votes should equal number of options (${options.length})`);
    for (const opt of body.options) {
      assert.equal(opt.vote_count, 1, `Each option should have exactly 1 vote, got ${opt.vote_count} for "${opt.text}"`);
    }
  });
});
