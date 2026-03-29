import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

export default function PointsGraph({ data }) {
  if (!data || data.length === 0) return <div>No data yet</div>;
  return (
    <ResponsiveContainer width="100%" height={300}>
      <BarChart data={data}>
        <CartesianGrid strokeDasharray="3 3" stroke="#333" />
        <XAxis dataKey="name" stroke="#ccc" />
        <YAxis stroke="#ccc" />
        <Tooltip contentStyle={{ backgroundColor: '#1a1f2f', border: 'none' }} />
        <Bar dataKey="points" fill="#00f3ff" />
      </BarChart>
    </ResponsiveContainer>
  );
}
