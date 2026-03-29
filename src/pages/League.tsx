import { useLeaderboard } from '../hooks/useLeaderboard';
import LeaderboardRow from '../components/LeaderboardRow';

export default function League() {
  const { leaderboard, loading } = useLeaderboard(null);

  if (loading) return <div>Loading leaderboard...</div>;

  return (
    <div className="glass-card p-6">
      <h2 className="text-2xl font-bold mb-4">Season Leaderboard</h2>
      <div className="space-y-2">
        {leaderboard?.map((entry, idx) => (
          <LeaderboardRow key={entry.user_id} rank={idx+1} name={entry.display_name} points={entry.points} />
        ))}
      </div>
    </div>
  );
}