import { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { TrendingUp, Users, Award } from 'lucide-react';
import { useAuth } from '../hooks/useAuth';
import { useLeaderboard } from '../hooks/useLeaderboard';
import { api } from '../utils/api';
import PointsGraph from '../components/PointsGraph';

export default function MatchCenter() {
  const { matchId } = useParams();
  const { user } = useAuth();
  const [match, setMatch] = useState(null);
  const [myTeam, setMyTeam] = useState(null);
  const { leaderboard, loading } = useLeaderboard(matchId);

  useEffect(() => {
    const fetchData = async () => {
      const matchData = await api.get(`matches?matchId=${matchId}`);
      setMatch(matchData);
      const teamData = await api.get(`entry-my-team?userId=${user.id}&matchId=${matchId}`);
      setMyTeam(teamData);
    };
    fetchData();
    const interval = setInterval(fetchData, 30000);
    return () => clearInterval(interval);
  }, [matchId, user.id]);

  if (!match || loading) return <div>Loading match center...</div>;

  return (
    <div className="space-y-6">
      <div className="glass-card p-6 text-center">
        <h1 className="text-3xl font-bold">{match.team_a?.name} vs {match.team_b?.name}</h1>
        <p className="text-gray-400">Status: {match.status}</p>
      </div>

      {myTeam?.exists && (
        <div className="glass-card p-6">
          <h2 className="text-2xl font-bold flex items-center gap-2"><Users /> Your XI</h2>
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-3 mt-4">
            {myTeam.players.map(p => (
              <div key={p.id} className="bg-white/5 p-2 rounded text-center">
                <div className="font-bold">{p.name}</div>
                <div className="text-sm text-neon-green">{p.fantasy_points} pts</div>
              </div>
            ))}
          </div>
          <div className="mt-4 text-xl">Total: {myTeam.entry.total_points} pts</div>
        </div>
      )}

      <div className="glass-card p-6">
        <h2 className="text-2xl font-bold flex items-center gap-2"><TrendingUp /> Live Leaderboard</h2>
        <div className="mt-4 space-y-2">
          {leaderboard?.map((entry, idx) => (
            <div key={entry.user_id} className="flex justify-between items-center p-2 border-b border-white/10">
              <div className="flex items-center gap-2">
                <span className="text-lg font-mono">#{idx+1}</span>
                <span className="font-bold">{entry.display_name}</span>
              </div>
              <div className="text-neon-blue">{entry.points} pts</div>
            </div>
          ))}
        </div>
      </div>

      <div className="glass-card p-6">
        <h2 className="text-2xl font-bold flex items-center gap-2"><Award /> Points Trend</h2>
        <PointsGraph data={leaderboard?.slice(0,5).map(entry => ({ name: entry.display_name, points: entry.points }))} />
      </div>
    </div>
  );
}
