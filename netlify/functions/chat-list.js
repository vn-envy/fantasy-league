const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event) => {
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const { matchId } = event.queryStringParameters;

  let query = supabase
    .from('chat_messages')
    .select(
      *,
      users (display_name)
    )
    .order('created_at', { ascending: false })
    .limit(50);

  if (matchId) {
    query = query.eq('match_id', matchId);
  }

  const { data, error } = await query;
  if (error) return { statusCode: 500, body: JSON.stringify({ error: error.message }) };

  const formatted = data.map(msg => ({
    ...msg,
    display_name: msg.users.display_name
  }));

  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(formatted)
  };
};
