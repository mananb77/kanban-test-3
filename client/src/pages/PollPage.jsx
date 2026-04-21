import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import PollVote from '../components/PollVote';
import PollResults from '../components/PollResults';

export default function PollPage() {
  const { id } = useParams();
  const [poll, setPoll] = useState(null);
  const [loading, setLoading] = useState(true);
  const [notFound, setNotFound] = useState(false);
  const [selectedIndex, setSelectedIndex] = useState(null);
  const [hasVoted, setHasVoted] = useState(false);
  const [voteError, setVoteError] = useState(null);
  const [voting, setVoting] = useState(false);
  const [copyConfirm, setCopyConfirm] = useState(false);
  const [showFallbackUrl, setShowFallbackUrl] = useState(false);

  useEffect(() => {
    fetch(`/api/polls/${id}`)
      .then(res => {
        if (res.status === 404) { setNotFound(true); return null; }
        if (!res.ok) { setNotFound(true); return null; }
        return res.json();
      })
      .then(data => { if (data) setPoll(data); })
      .catch(() => setNotFound(true))
      .finally(() => setLoading(false));
  }, [id]);

  async function handleVote() {
    if (selectedIndex === null) return;
    setVoteError(null);
    setVoting(true);
    try {
      const res = await fetch(`/api/polls/${id}/vote`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ optionIndex: selectedIndex })
      });
      const data = await res.json();
      if (!res.ok) {
        setVoteError(data.error || 'Failed to submit vote.');
        return;
      }
      setPoll(data);
      setHasVoted(true);
    } catch {
      setVoteError('Network error. Please try again.');
    } finally {
      setVoting(false);
    }
  }

  function handleCopyLink() {
    navigator.clipboard.writeText(window.location.href)
      .then(() => {
        setCopyConfirm(true);
        setTimeout(() => setCopyConfirm(false), 2000);
      })
      .catch(() => setShowFallbackUrl(true));
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <p className="text-gray-500">Loading...</p>
      </div>
    );
  }

  if (notFound) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center px-4">
        <div className="text-center">
          <h2 className="text-2xl font-bold text-gray-800 mb-2">Poll not found</h2>
          <p className="text-gray-500 mb-4">This poll doesn't exist or may have been removed.</p>
          <Link to="/" className="text-blue-600 hover:underline focus:outline-none focus:ring-2 focus:ring-blue-500 rounded">
            ← Create a new poll
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 flex items-start justify-center py-12 px-4">
      <div className="w-full max-w-lg bg-white rounded-2xl shadow-sm border border-gray-200 p-8">
        <div className="flex items-start justify-between gap-4 mb-6">
          <h1 className="text-xl font-bold text-gray-900 leading-snug">{poll.question}</h1>
          <div className="flex flex-col items-end gap-1 shrink-0">
            <button
              onClick={handleCopyLink}
              className="text-sm text-blue-600 hover:text-blue-800 font-medium border border-blue-200 rounded-lg px-3 py-1 whitespace-nowrap focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              {copyConfirm ? 'Copied!' : 'Copy Link'}
            </button>
            {showFallbackUrl && (
              <input
                type="text"
                readOnly
                value={window.location.href}
                className="text-xs border border-gray-300 rounded px-2 py-1 w-48 text-gray-600 focus:outline-none focus:ring-2 focus:ring-blue-500"
                onFocus={e => e.target.select()}
              />
            )}
          </div>
        </div>

        {hasVoted ? (
          <PollResults options={poll.options} />
        ) : (
          <>
            <PollVote
              options={poll.options}
              selectedIndex={selectedIndex}
              onSelect={setSelectedIndex}
            />

            {voteError && (
              <p className="mt-3 text-sm text-red-600" role="alert">{voteError}</p>
            )}

            <button
              onClick={handleVote}
              disabled={selectedIndex === null || voting}
              className="mt-4 w-full bg-blue-600 text-white font-semibold py-2 px-4 rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
            >
              {voting ? 'Submitting...' : 'Vote'}
            </button>
          </>
        )}
      </div>
    </div>
  );
}
