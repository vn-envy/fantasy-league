const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event) => {
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const { inviteCode, displayName } = JSON.parse(event.body);

  const { data: user, error: userError } = await supabase
    .from('users')
    .insert({ display_name: displayName, invite_code: inviteCode })
    .select()
    .single();
  if (userError) return { statusCode: 500, body: JSON.stringify({ error: userError.message }) };

  const { data: league } = await supabase
    .from('leagues')
    .select('id')
    .limit(1)
    .single();

  await supabase
    .from('league_members')
    .insert({ league_id: league.id, user_id: user.id });

  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ userId: user.id })
  };
};
