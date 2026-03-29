import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { format } from 'date-fns';
import { Calendar, Clock, TrendingUp, MessageSquare } from 'lucide-react';
import CountdownTimer from '../components/CountdownTimer';
import { useMatches } from '../hooks/useMatches';
import { useLeaderboard } from '../hooks/useLeaderboard';

export default function Landing() {
  const { matches, loading: matchesLoading } = useMatches();
  const { leaderboard, loading: leaderboardLoading } = useLeaderboard(null);
  const [nextMatch, setNextMatch] = useState(null);

  useEffect(() => {
    if (matches && matches.length) {
      const upcoming = matches.find(m => new Date(m.starts_at) > new Date());
      setNextMatch(upcoming);
    }
  }, [matches]);

  if (matchesLoading || leaderboardLoading) return <div className="text-center">Loading...</div>;

  return (
    <div className="space-y-8">
      <div className="glass-card p-8 text-center relative overflow-hidden">
        <div className="absolute inset-0 opacity-10 bg-[url('https://cdn-icons-png.flaticon.com/512/4038/4038677.png')] bg-no-repeat bg-center bg-contain"></div>
        <h1 className="text-5xl font-bold bg-gradient-to-r from-neon-blue via-neon-pink to-neon-green bg-clip-text text-transparent">
          IPL War Room
        </h1>
        <p className="text-xl text-gray-300 mt-4">Your private league. Banter. Bragging rights.</p>
        {nextMatch && (
          <div className="mt-6">
            <div className="text-2xl font-mono">{nextMatch.team_a?.name} vs {nextMatch.team_b?.name}</div>
            <div className="flex justify-center items-center space-x-4 mt-2 text-gray-400">
              <Calendar size={18} /><span>{format(new Date(nextMatch.starts_at), 'dd MMM yyyy')}</span>
              <Clock size={18} /><span>{format(new Date(nextMatch.starts_at), 'hh:mm a')}</span>
            </div>
            <div className="mt-4">
              <CountdownTimer targetDate={new Date(nextMatch.starts_at)} />
            </div>
            <Link to={`/pick/${nextMatch.id}`} className="btn-primary inline-block mt-6">
              Pick Your XI
            </Link>
          </div>
        )}
      </div>

      <div className="glass-card p-6">
        <h2 className="text-2xl font-bold flex items-center gap-2"><TrendingUp className="text-neon-green" /> Top Guns</h2>
        <div className="mt-4 grid grid-cols-1 md:grid-cols-3 gap-4">
          {leaderboard?.slice(0,3).map((entry, idx) => (
            <div key={entry.user_id} className="bg-white/5 rounded-lg p-4 text-center">
              <div className="text-3xl font-bold text-neon-pink">#{idx+1}</div>
              <div className="text-xl mt-2">{entry.display_name}</div>
              <div className="text-2xl font-mono mt-1">{entry.points} pts</div>
            </div>
          ))}
        </div>
      </div>

      <div className="glass-card p-6">
        <h2 className="text-2xl font-bold flex items-center gap-2"><MessageSquare size={24} /> Banter Wall</h2>
        <div className="mt-4 space-y-2">
          <p className="text-gray-400 italic">"Rohit carry job incoming!" - ViratFan</p>
          <p className="text-gray-400 italic">"My captain is gonna smash today" - SKY_22</p>
        </div>
        <Link to="/banter/1" className="text-neon-blue hover:underline mt-2 inline-block">Join the banter →</Link>
      </div>
    </div>
  );
}