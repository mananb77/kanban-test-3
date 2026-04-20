export default function PollForm({ question, options, onQuestionChange, onOptionChange, onAddOption, onRemoveOption, onSubmit, error, submitting }) {
  return (
    <form onSubmit={onSubmit} className="flex flex-col gap-4">
      <div>
        <label htmlFor="question" className="block text-sm font-medium text-gray-700 mb-1">
          Question
        </label>
        <input
          id="question"
          type="text"
          value={question}
          onChange={e => onQuestionChange(e.target.value)}
          placeholder="Your question..."
          className="w-full border border-gray-300 rounded-lg px-4 py-2 text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        />
      </div>

      <div className="flex flex-col gap-2">
        <span className="text-sm font-medium text-gray-700">Options</span>
        {options.map((opt, i) => (
          <div key={i} className="flex gap-2 items-center">
            <input
              type="text"
              value={opt}
              onChange={e => onOptionChange(i, e.target.value)}
              placeholder={`Option ${i + 1}`}
              className="flex-1 border border-gray-300 rounded-lg px-4 py-2 text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
            {i >= 2 && (
              <button
                type="button"
                onClick={() => onRemoveOption(i)}
                className="text-sm text-red-500 hover:text-red-700 px-2 py-1 rounded focus:outline-none focus:ring-2 focus:ring-red-400"
                aria-label={`Remove option ${i + 1}`}
              >
                Remove
              </button>
            )}
          </div>
        ))}

        {options.length < 6 && (
          <button
            type="button"
            onClick={onAddOption}
            className="self-start text-sm text-blue-600 hover:text-blue-800 font-medium focus:outline-none focus:ring-2 focus:ring-blue-500 rounded px-1"
          >
            + Add Option
          </button>
        )}
      </div>

      {error && (
        <p className="text-sm text-red-600" role="alert">{error}</p>
      )}

      <button
        type="submit"
        disabled={submitting || !question.trim() || options.filter(o => o.trim()).length < 2}
        className="w-full bg-blue-600 text-white font-semibold py-2 px-4 rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
      >
        {submitting ? 'Creating...' : 'Create Poll'}
      </button>
    </form>
  );
}
