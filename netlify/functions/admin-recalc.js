const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event) => {
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const { matchId } = JSON.parse(event.body);

  const { data: entries, error: entriesError } = await supabase
    .from('user_match_entries')
    .select('id, captain_player_id, vice_captain_player_id')
    .eq('match_id', matchId);
  if (entriesError) return { statusCode: 500, body: JSON.stringify({ error: entriesError.message }) };

  for (const entry of entries) {
    const { data: entryPlayers, error: playersError } = await supabase
      .from('user_match_entry_players')
      .select('player_id')
      .eq('entry_id', entry.id);
    if (playersError) return { statusCode: 500, body: JSON.stringify({ error: playersError.message }) };

    const playerIds = entryPlayers.map(p => p.player_id);
    const { data: stats, error: statsError } = await supabase
      .from('player_match_stats')
      .select('player_id, fantasy_points_raw')
      .eq('match_id', matchId)
      .in('player_id', playerIds);
    if (statsError) return { statusCode: 500, body: JSON.stringify({ error: statsError.message }) };

    let total = 0;
    for (const stat of stats) {
      let points = stat.fantasy_points_raw;
      if (stat.player_id === entry.captain_player_id) points *= 2;
      else if (stat.player_id === entry.vice_captain_player_id) points *= 1.5;
      total += points;
    }

    await supabase
      .from('user_match_entries')
      .update({ total_points: total })
      .eq('id', entry.id);
  }

  return { statusCode: 200, body: JSON.stringify({ message: 'Recalculation done' }) };
};
