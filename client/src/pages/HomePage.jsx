import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import PollForm from '../components/PollForm';

export default function HomePage() {
  const navigate = useNavigate();
  const [question, setQuestion] = useState('');
  const [options, setOptions] = useState(['', '']);
  const [error, setError] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  function handleAddOption() {
    if (options.length < 6) setOptions([...options, '']);
  }

  function handleRemoveOption(index) {
    setOptions(options.filter((_, i) => i !== index));
  }

  function handleOptionChange(index, value) {
    const updated = [...options];
    updated[index] = value;
    setOptions(updated);
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setError(null);

    if (!question.trim()) {
      setError('Question is required.');
      return;
    }
    const filledOptions = options.filter(o => o.trim());
    if (filledOptions.length < 2) {
      setError('At least 2 options are required.');
      return;
    }

    setSubmitting(true);
    try {
      const res = await fetch('/api/polls', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ question: question.trim(), options: filledOptions })
      });
      const data = await res.json();
      if (!res.ok) {
        setError(data.error || 'Failed to create poll.');
        return;
      }
      navigate(`/poll/${data.id}`);
    } catch {
      setError('Network error. Please try again.');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="min-h-screen bg-gray-50 flex items-start justify-center py-12 px-4">
      <div className="w-full max-w-lg bg-white rounded-2xl shadow-sm border border-gray-200 p-8">
        <h1 className="text-2xl font-bold text-gray-900 mb-6">Create a Poll</h1>
        <PollForm
          question={question}
          options={options}
          onQuestionChange={setQuestion}
          onOptionChange={handleOptionChange}
          onAddOption={handleAddOption}
          onRemoveOption={handleRemoveOption}
          onSubmit={handleSubmit}
          error={error}
          submitting={submitting}
        />
      </div>
    </div>
  );
}
