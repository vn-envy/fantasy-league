const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event) => {
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const { name, adminDisplayName } = JSON.parse(event.body);

  const generateCode = () => Math.random().toString(36).substring(2, 10).toUpperCase();
  const adminCode = generateCode();

  const { data: user, error: userError } = await supabase
    .from('users')
    .insert({ display_name: adminDisplayName, invite_code: adminCode })
    .select()
    .single();
  if (userError) return { statusCode: 500, body: JSON.stringify({ error: userError.message }) };

  const { data: league, error: leagueError } = await supabase
    .from('leagues')
    .insert({ name, admin_user_id: user.id, season_year: new Date().getFullYear() })
    .select()
    .single();
  if (leagueError) return { statusCode: 500, body: JSON.stringify({ error: leagueError.message }) };

  await supabase
    .from('league_members')
    .insert({ league_id: league.id, user_id: user.id });

  const codes = Array.from({ length: 12 }, () => generateCode());

  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ leagueId: league.id, adminCode, codes })
  };
};
