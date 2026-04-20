import { useState, useEffect } from 'react';

export default function PollResults({ options }) {
  const [animated, setAnimated] = useState(false);

  useEffect(() => {
    // Trigger animation on next tick so bars transition from 0% to actual width
    const id = setTimeout(() => setAnimated(true), 50);
    return () => clearTimeout(id);
  }, []);

  const total = options.reduce((sum, o) => sum + o.vote_count, 0);
  const maxVotes = Math.max(...options.map(o => o.vote_count));

  return (
    <div className="flex flex-col gap-3">
      {options.map(o => {
        const pct = total === 0 ? 0 : (o.vote_count / total) * 100;
        const isLeader = o.vote_count > 0 && o.vote_count === maxVotes;

        return (
          <div key={o.id} className="flex flex-col gap-1">
            <div className="flex justify-between text-sm text-gray-700">
              <span className={isLeader ? 'font-semibold text-blue-700' : ''}>{o.text}</span>
              <span>{o.vote_count}</span>
            </div>
            <div className="w-full bg-gray-100 rounded-full h-4 overflow-hidden">
              <div
                className={`h-full rounded-full transition-all duration-500 ease-out ${isLeader ? 'bg-blue-600' : 'bg-blue-400'}`}
                style={{ width: animated ? `${pct}%` : '0%', minWidth: pct > 0 ? '4px' : '0' }}
                role="progressbar"
                aria-valuenow={o.vote_count}
                aria-valuemin={0}
                aria-valuemax={total}
                aria-label={o.text}
              />
            </div>
          </div>
        );
      })}

      <p className="text-sm text-gray-500 mt-2">
        Total votes: <span className="font-medium text-gray-700">{total}</span>
      </p>
    </div>
  );
}
