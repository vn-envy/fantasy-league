const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event) => {
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const { matchId } = event.queryStringParameters;

  if (matchId) {
    const { data, error } = await supabase
      .from('matches')
      .select(
        *,
        team_a:team_a_id(name),
        team_b:team_b_id(name)
      )
      .eq('id', matchId)
      .single();
    if (error) return { statusCode: 500, body: JSON.stringify({ error: error.message }) };
    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    };
  } else {
    const { data, error } = await supabase
      .from('matches')
      .select(
        *,
        team_a:team_a_id(name),
        team_b:team_b_id(name)
      )
      .gte('starts_at', new Date().toISOString())
      .order('starts_at');
    if (error) return { statusCode: 500, body: JSON.stringify({ error: error.message }) };
    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    };
  }
};
