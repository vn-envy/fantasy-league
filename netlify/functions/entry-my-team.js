const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event) => {
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const { userId, matchId } = event.queryStringParameters;
  if (!userId || !matchId) return { statusCode: 400, body: 'userId and matchId required' };

  const { data: entry, error: entryError } = await supabase
    .from('user_match_entries')
    .select(
      *,
      captain:captain_player_id(name),
      vice_captain:vice_captain_player_id(name)
    )
    .eq('user_id', userId)
    .eq('match_id', matchId)
    .maybeSingle();

  if (entryError) return { statusCode: 500, body: JSON.stringify({ error: entryError.message }) };
  if (!entry) {
    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ exists: false })
    };
  }

  const { data: players, error: playersError } = await supabase
    .from('user_match_entry_players')
    .select('player_id')
    .eq('entry_id', entry.id);

  if (playersError) return { statusCode: 500, body: JSON.stringify({ error: playersError.message }) };

  const playerIds = players.map(p => p.player_id);
  const { data: playerDetails, error: detailsError } = await supabase
    .from('players')
    .select('*, teams!inner(name)')
    .in('id', playerIds);
  if (detailsError) return { statusCode: 500, body: JSON.stringify({ error: detailsError.message }) };

  const { data: stats, error: statsError } = await supabase
    .from('player_match_stats')
    .select('player_id, fantasy_points_raw')
    .eq('match_id', matchId)
    .in('player_id', playerIds);
  if (statsError) return { statusCode: 500, body: JSON.stringify({ error: statsError.message }) };

  const statsMap = new Map(stats.map(s => [s.player_id, s.fantasy_points_raw]));

  const enrichedPlayers = playerDetails.map(p => ({
    ...p,
    team_name: p.teams.name,
    fantasy_points: statsMap.get(p.id) || 0
  }));

  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      exists: true,
      entry: {
        ...entry,
        captain_name: entry.captain?.name,
        vice_captain_name: entry.vice_captain?.name
      },
      players: enrichedPlayers
    })
  };
};
