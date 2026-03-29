const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event) => {
  if (event.headers['x-netlify-event'] !== 'scheduled') {
    return { statusCode: 404 };
  }

  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const { data: liveMatches, error: matchError } = await supabase
    .from('matches')
    .select('*')
    .eq('status', 'live');
  if (matchError) return { statusCode: 500, body: JSON.stringify({ error: matchError.message }) };

  for (const match of liveMatches) {
    const apiKey = process.env.CRICKET_API_KEY;
    const response = await fetch(
      https://api.cricketdata.com/v1/match//stats?apikey=
    );
    const statsData = await response.json();

    for (const playerStat of statsData.players) {
      const rawPoints = calcPoints(playerStat);
      await supabase
        .from('player_match_stats')
        .upsert({
          match_id: match.id,
          player_id: playerStat.player_id,
          runs: playerStat.runs,
          fours: playerStat.fours,
          sixes: playerStat.sixes,
          wickets: playerStat.wickets,
          maidens: playerStat.maidens,
          catches: playerStat.catches,
          stumpings: playerStat.stumpings,
          runouts: playerStat.runouts,
          in_playing_xi: playerStat.in_playing_xi,
          fantasy_points_raw: rawPoints,
          updated_at: new Date().toISOString()
        }, { onConflict: 'match_id,player_id' });
    }

    await recalcMatchEntries(supabase, match.id);
  }

  return { statusCode: 200 };
};

function calcPoints(stats) {
  let pts = 0;
  pts += stats.in_playing_xi ? 4 : 0;
  pts += stats.runs * 1;
  pts += stats.fours * 1;
  pts += stats.sixes * 2;
  pts += stats.wickets * 25;
  pts += stats.maidens * 8;
  pts += stats.catches * 8;
  pts += stats.stumpings * 12;
  pts += stats.runouts * 12;
  return pts;
}

async function recalcMatchEntries(supabase, matchId) {
  const { data: entries, error } = await supabase
    .from('user_match_entries')
    .select('id, captain_player_id, vice_captain_player_id')
    .eq('match_id', matchId);
  if (error) throw error;

  for (const entry of entries) {
    const { data: entryPlayers, error: playersError } = await supabase
      .from('user_match_entry_players')
      .select('player_id')
      .eq('entry_id', entry.id);
    if (playersError) throw playersError;

    const playerIds = entryPlayers.map(p => p.player_id);
    const { data: stats, error: statsError } = await supabase
      .from('player_match_stats')
      .select('player_id, fantasy_points_raw')
      .eq('match_id', matchId)
      .in('player_id', playerIds);
    if (statsError) throw statsError;

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
}
