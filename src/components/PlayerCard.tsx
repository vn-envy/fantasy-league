import { CheckCircle, Crown, Star } from 'lucide-react';

export default function PlayerCard({ player, selected, onToggle, isCaptain, onCaptain, isViceCaptain, onViceCaptain, disabled }) {
  return (
    <div className={`glass-card p-4 transition-all ${selected ? 'border-neon-blue border' : ''}`}>
      <div className="flex justify-between items-start">
        <div>
          <h3 className="text-lg font-bold">{player.name}</h3>
          <p className="text-sm text-gray-400">{player.team_name} • {player.role}</p>
          <p className="text-neon-green mt-1">Credits: {player.credit_value}</p>
        </div>
        <button onClick={onToggle} className={`p-2 rounded-full ${selected ? 'bg-neon-blue text-tech-dark' : 'bg-white/10'}`}>
          {selected ? <CheckCircle size={18} /> : '+'}
        </button>
      </div>
      {selected && (
        <div className="flex gap-2 mt-3">
          <button
            onClick={onCaptain}
            disabled={disabled}
            className={`flex items-center gap-1 px-2 py-1 rounded ${isCaptain ? 'bg-yellow-500 text-tech-dark' : 'bg-white/10'}`}
          >
            <Crown size={14} /> C
          </button>
          <button
            onClick={onViceCaptain}
            disabled={disabled}
            className={`flex items-center gap-1 px-2 py-1 rounded ${isViceCaptain ? 'bg-gray-300 text-tech-dark' : 'bg-white/10'}`}
          >
            <Star size={14} /> VC
          </button>
        </div>
      )}
    </div>
  );
}
