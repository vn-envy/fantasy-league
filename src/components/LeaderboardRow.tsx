export default function LeaderboardRow({ rank, name, points }) {
  const medalColors = ['text-yellow-400', 'text-gray-300', 'text-amber-600'];
  return (
    <div className="flex justify-between items-center p-3 border-b border-white/10">
      <div className="flex items-center gap-3">
        <span className={`text-2xl font-mono ${rank <= 3 ? medalColors[rank-1] : 'text-gray-500'}`}>#{rank}</span>
        <span className="font-bold">{name}</span>
      </div>
      <div className="text-neon-blue text-xl">{points} pts</div>
    </div>
  );
}