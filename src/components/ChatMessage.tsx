import { formatDistanceToNow } from 'date-fns';

export default function ChatMessage({ message, isOwn }) {
  return (
    <div className={`flex ${isOwn ? 'justify-end' : 'justify-start'}`}>
      <div className={`max-w-[70%] rounded-lg p-3 ${isOwn ? 'bg-neon-blue text-tech-dark' : 'bg-white/10'}`}>
        <div className="text-sm font-bold">{message.display_name}</div>
        <div>{message.message}</div>
        <div className="text-xs mt-1 opacity-70">{formatDistanceToNow(new Date(message.created_at))} ago</div>
      </div>
    </div>
  );
}