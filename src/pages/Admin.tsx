import { useState } from 'react';
import { api } from '../utils/api';

export default function Admin() {
  const [matchId, setMatchId] = useState('');
  const [status, setStatus] = useState('');

  const recalcPoints = async () => {
    await api.post('admin-recalc', { matchId });
    setStatus('Recalculation triggered');
  };

  const lockMatch = async () => {
    setStatus('Locked (not implemented)');
  };

  return (
    <div className="glass-card p-6">
      <h2 className="text-2xl font-bold mb-4">Admin Panel</h2>
      <div className="space-y-4">
        <div>
          <label className="block text-sm">Match ID</label>
          <input
            type="text"
            value={matchId}
            onChange={(e) => setMatchId(e.target.value)}
            className="bg-white/10 rounded px-3 py-2 w-full"
          />
        </div>
        <div className="flex gap-2">
          <button onClick={recalcPoints} className="btn-primary">Recalc Points</button>
          <button onClick={lockMatch} className="btn-secondary">Force Lock</button>
        </div>
        {status && <div className="text-neon-green">{status}</div>}
      </div>
    </div>
  );
}
