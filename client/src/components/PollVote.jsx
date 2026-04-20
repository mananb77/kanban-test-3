export default function PollVote({ options, selectedIndex, onSelect }) {
  return (
    <div className="flex flex-col gap-3" role="radiogroup">
      {options.map((opt, i) => (
        <div
          key={opt.id}
          role="radio"
          aria-checked={selectedIndex === i}
          tabIndex={0}
          onClick={() => onSelect(i)}
          onKeyDown={e => (e.key === 'Enter' || e.key === ' ') && onSelect(i)}
          className={`cursor-pointer rounded-lg border-2 px-4 py-3 transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 ${
            selectedIndex === i
              ? 'border-blue-500 bg-blue-50 text-blue-900'
              : 'border-gray-200 bg-white text-gray-800 hover:border-blue-300 hover:bg-blue-50/50'
          }`}
        >
          {opt.text}
        </div>
      ))}
    </div>
  );
}
