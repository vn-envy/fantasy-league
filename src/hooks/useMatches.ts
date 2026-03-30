import { useState, useEffect } from 'react';
import { api } from '../utils/api';

export function useMatches() {
  const [matches, setMatches] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let mounted = true;

    const fetchMatches = async () => {
      try {
        const data = await api.get('matches');
        if (mounted) setMatches(data || []);
      } catch (error) {
        console.error('Failed to load matches:', error);
        if (mounted) setMatches([]);
      } finally {
        if (mounted) setLoading(false);
      }
    };

    fetchMatches();

    return () => {
      mounted = false;
    };
  }, []);

  return { matches, loading };
}
