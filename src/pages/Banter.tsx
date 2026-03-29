import { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { Send } from 'lucide-react';
import { useAuth } from '../hooks/useAuth';
import { api } from '../utils/api';
import ChatMessage from '../components/ChatMessage';

export default function Banter() {
  const { matchId } = useParams();
  const { user } = useAuth();
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');

  const fetchMessages = async () => {
    const data = await api.get(`chat-list?matchId=${matchId}`);
    setMessages(data);
  };

  useEffect(() => {
    fetchMessages();
    const interval = setInterval(fetchMessages, 5000);
    return () => clearInterval(interval);
  }, [matchId]);

  const sendMessage = async () => {
    if (!newMessage.trim()) return;
    await api.post('chat-post', { userId: user.id, matchId, message: newMessage });
    setNewMessage('');
    fetchMessages();
  };

  return (
    <div className="glass-card p-6 h-[80vh] flex flex-col">
      <h2 className="text-2xl font-bold mb-4">Banter Wall</h2>
      <div className="flex-1 overflow-y-auto space-y-3 mb-4">
        {messages.map(msg => (
          <ChatMessage key={msg.id} message={msg} isOwn={msg.user_id === user.id} />
        ))}
      </div>
      <div className="flex gap-2">
        <input
          type="text"
          value={newMessage}
          onChange={(e) => setNewMessage(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && sendMessage()}
          placeholder="Drop some banter..."
          className="flex-1 bg-white/10 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-neon-blue"
        />
        <button onClick={sendMessage} className="btn-primary"><Send size={20} /></button>
      </div>
    </div>
  );
}