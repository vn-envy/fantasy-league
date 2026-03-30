import { useState, useEffect } from 'react';
import { api } from '../utils/api';

export function useLeaderboard(matchId) {
  const [leaderboard, setLeaderboard] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let mounted = true;

    const fetchLeaderboard = async () => {
      try {
        const url = matchId ? `leaderboard?matchId=${matchId}` : 'leaderboard';
        const data = await api.get(url);
        if (mounted) setLeaderboard(data || []);
      } catch (error) {
        console.error('Failed to load leaderboard:', error);
        if (mounted) setLeaderboard([]);
      } finally {
        if (mounted) setLoading(false);
      }
    };

    fetchLeaderboard();
    if (matchId) {
      const interval = setInterval(fetchLeaderboard, 30000);
      return () => {
        mounted = false;
        clearInterval(interval);
      };
    }

    return () => {
      mounted = false;
    };
  }, [matchId]);

  return { leaderboard, loading };
}
