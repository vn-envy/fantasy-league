const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event) => {
  try {
    const supabase = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_ANON_KEY
    );

    const { matchId } = event.queryStringParameters || {};

    if (matchId) {
      const { data, error } = await supabase
        .from('user_match_entries')
        .select(`
          user_id,
          total_points,
          users (display_name)
        `)
        .eq('match_id', matchId)
        .order('total_points', { ascending: false });

      if (error) return { statusCode: 500, body: JSON.stringify({ error: error.message }) };
      const formatted = (data || []).map((entry) => ({
        user_id: entry.user_id,
        display_name: entry.users?.display_name,
        points: entry.total_points || 0
      }));

      return {
        statusCode: 200,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formatted)
      };
    }

    const { data, error } = await supabase
      .from('user_match_entries')
      .select(`
        user_id,
        total_points,
        users (display_name)
      `);

    if (error) return { statusCode: 500, body: JSON.stringify({ error: error.message }) };

    const totals = (data || []).reduce((acc, entry) => {
      if (!acc[entry.user_id]) {
        acc[entry.user_id] = {
          user_id: entry.user_id,
          display_name: entry.users?.display_name,
          points: 0
        };
      }
      acc[entry.user_id].points += entry.total_points || 0;
      return acc;
    }, {});

    const board = Object.values(totals).sort((a, b) => b.points - a.points);
    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(board)
    };
  } catch (error) {
    return { statusCode: 500, body: JSON.stringify({ error: error.message || 'Unexpected error' }) };
  }
};
