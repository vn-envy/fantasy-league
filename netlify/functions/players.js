const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event) => {
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const { matchId } = event.queryStringParameters;
  if (!matchId) return { statusCode: 400, body: 'matchId required' };

  const { data: match, error: matchError } = await supabase
    .from('matches')
    .select('team_a_id, team_b_id')
    .eq('id', matchId)
    .single();
  if (matchError) return { statusCode: 500, body: JSON.stringify({ error: matchError.message }) };

  const { data: players, error: playersError } = await supabase
    .from('players')
    .select('*, teams!inner(name)')
    .in('team_id', [match.team_a_id, match.team_b_id])
    .eq('is_active', true)
    .order('team_id')
    .order('name');
  if (playersError) return { statusCode: 500, body: JSON.stringify({ error: playersError.message }) };

  const formatted = players.map(p => ({
    ...p,
    team_name: p.teams.name
  }));

  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(formatted)
  };
};
