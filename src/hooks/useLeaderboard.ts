import { useState, useEffect } from 'react';
import { api } from '../utils/api';

export function useLeaderboard(matchId) {
  const [leaderboard, setLeaderboard] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchLeaderboard = async () => {
      const url = matchId ? `leaderboard?matchId=${matchId}` : 'leaderboard';
      const data = await api.get(url);
      setLeaderboard(data);
      setLoading(false);
    };
    fetchLeaderboard();
    if (matchId) {
      const interval = setInterval(fetchLeaderboard, 30000);
      return () => clearInterval(interval);
    }
  }, [matchId]);

  return { leaderboard, loading };
}