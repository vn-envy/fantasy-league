import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Users, Shield, Star, AlertTriangle } from 'lucide-react';
import { useAuth } from '../hooks/useAuth';
import { api } from '../utils/api';
import PlayerCard from '../components/PlayerCard';

export default function PickXI() {
  const { matchId } = useParams();
  const { user } = useAuth();
  const navigate = useNavigate();
  const [players, setPlayers] = useState([]);
  const [selected, setSelected] = useState([]);
  const [captain, setCaptain] = useState(null);
  const [viceCaptain, setViceCaptain] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchPlayers = async () => {
      const data = await api.get(`players?matchId=${matchId}`);
      setPlayers(data);
      setLoading(false);
    };
    fetchPlayers();
  }, [matchId]);

  const togglePlayer = (playerId) => {
    if (selected.includes(playerId)) {
      setSelected(selected.filter(id => id !== playerId));
      if (captain === playerId) setCaptain(null);
      if (viceCaptain === playerId) setViceCaptain(null);
    } else {
      if (selected.length >= 11) {
        setError('You can only pick 11 players');
        return;
      }
      setSelected([...selected, playerId]);
      setError('');
    }
  };

  const creditsUsed = players
    .filter(p => selected.includes(p.id))
    .reduce((sum, p) => sum + p.credit_value, 0);
  const creditsLeft = 100 - creditsUsed;

  const teamCounts = players
    .filter(p => selected.includes(p.id))
    .reduce((acc, p) => {
      acc[p.team_name] = (acc[p.team_name] || 0) + 1;
      return acc;
    }, {});
  const teamViolation = Object.values(teamCounts).some(count => count > 7);

  const handleSubmit = async () => {
    if (selected.length !== 11) {
      setError('Pick exactly 11 players');
      return;
    }
    if (!captain) {
      setError('Select a captain');
      return;
    }
    if (!viceCaptain) {
      setError('Select a vice-captain');
      return;
    }
    if (teamViolation) {
      setError('Max 7 players from one team');
      return;
    }
    if (creditsLeft < 0) {
      setError('Credits exceeded');
      return;
    }

    try {
      await api.post('entry-save', {
        userId: user.id,
        matchId,
        captainId: captain,
        viceCaptainId: viceCaptain,
        playerIds: selected
      });
      navigate(`/match/${matchId}`);
    } catch (err) {
      setError('Failed to save team');
    }
  };

  if (loading) return <div className="text-center">Loading players...</div>;

  return (
    <div className="space-y-6">
      <div className="glass-card p-6 sticky top-4 z-10">
        <div className="flex flex-wrap justify-between items-center gap-4">
          <div className="flex items-center gap-2"><Users /> Players: {selected.length}/11</div>
          <div className="flex items-center gap-2"><Shield /> Credits: {creditsLeft}/100</div>
          <div className="flex items-center gap-2"><Star /> Captain: {captain ? players.find(p => p.id === captain)?.name : 'Not set'}</div>
          <div className="flex items-center gap-2"><Star /> VC: {viceCaptain ? players.find(p => p.id === viceCaptain)?.name : 'Not set'}</div>
          {teamViolation && <div className="text-red-500 flex items-center gap-1"><AlertTriangle size={16} /> Max 7 per team</div>}
          <button onClick={handleSubmit} className="btn-primary">Lock Team</button>
        </div>
        {error && <div className="text-red-500 mt-2">{error}</div>}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {players.map(player => (
          <PlayerCard
            key={player.id}
            player={player}
            selected={selected.includes(player.id)}
            onToggle={() => togglePlayer(player.id)}
            isCaptain={captain === player.id}
            onCaptain={() => setCaptain(player.id)}
            isViceCaptain={viceCaptain === player.id}
            onViceCaptain={() => setViceCaptain(player.id)}
            disabled={!selected.includes(player.id)}
          />
        ))}
      </div>
    </div>
  );
}
