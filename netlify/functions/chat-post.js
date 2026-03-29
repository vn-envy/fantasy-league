const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event) => {
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const { userId, matchId, message } = JSON.parse(event.body);

  const { data: league } = await supabase
    .from('leagues')
    .select('id')
    .limit(1)
    .single();
  const leagueId = league.id;

  const { error } = await supabase
    .from('chat_messages')
    .insert({
      league_id: leagueId,
      match_id: matchId || null,
      user_id: userId,
      message
    });

  if (error) return { statusCode: 500, body: JSON.stringify({ error: error.message }) };
  return { statusCode: 200, body: 'OK' };
};
