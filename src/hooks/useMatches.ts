import { useState, useEffect } from 'react';
import { api } from '../utils/api';

export function useMatches() {
  const [matches, setMatches] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('matches').then(data => {
      setMatches(data);
      setLoading(false);
    });
  }, []);

  return { matches, loading };
}