const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event) => {
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const { userId, matchId, captainId, viceCaptainId, playerIds } = JSON.parse(event.body);

  const { data: match, error: matchError } = await supabase
    .from('matches')
    .select('starts_at')
    .eq('id', matchId)
    .single();
  if (matchError) return { statusCode: 500, body: JSON.stringify({ error: matchError.message }) };
  if (new Date(match.starts_at) <= new Date()) {
    return { statusCode: 403, body: 'Match locked' };
  }

  const { data: players, error: playersError } = await supabase
    .from('players')
    .select('credit_value')
    .in('id', playerIds);
  if (playersError) return { statusCode: 500, body: JSON.stringify({ error: playersError.message }) };
  const creditsUsed = players.reduce((sum, p) => sum + p.credit_value, 0);
  if (creditsUsed > 100) return { statusCode: 400, body: 'Credits exceed 100' };

  const { data: teamCounts, error: teamError } = await supabase
    .from('players')
    .select('team_id')
    .in('id', playerIds);
  if (teamError) return { statusCode: 500, body: JSON.stringify({ error: teamError.message }) };
  const counts = teamCounts.reduce((acc, p) => {
    acc[p.team_id] = (acc[p.team_id] || 0) + 1;
    return acc;
  }, {});
  if (Object.values(counts).some(c => c > 7)) {
    return { statusCode: 400, body: 'Max 7 players per team' };
  }

  const { data: league } = await supabase
    .from('leagues')
    .select('id')
    .limit(1)
    .single();
  const leagueId = league.id;

  const { data: entry, error: entryError } = await supabase
    .from('user_match_entries')
    .insert({
      league_id: leagueId,
      match_id: matchId,
      user_id: userId,
      captain_player_id: captainId,
      vice_captain_player_id: viceCaptainId,
      credits_used: creditsUsed,
      locked_at: new Date().toISOString()
    })
    .select()
    .single();
  if (entryError) return { statusCode: 500, body: JSON.stringify({ error: entryError.message }) };

  const entryPlayers = playerIds.map(pid => ({
    entry_id: entry.id,
    player_id: pid
  }));
  const { error: insertError } = await supabase
    .from('user_match_entry_players')
    .insert(entryPlayers);
  if (insertError) return { statusCode: 500, body: JSON.stringify({ error: insertError.message }) };

  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ entryId: entry.id })
  };
};
