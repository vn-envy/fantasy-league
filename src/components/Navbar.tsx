import { Link, useLocation } from 'react-router-dom';
import { Trophy, Users, MessageSquare, Shield } from 'lucide-react';

export default function Navbar() {
  const location = useLocation();
  const isAdmin = localStorage.getItem('isAdmin') === 'true';

  return (
    <nav className="glass-card mx-4 mt-4 px-6 py-3">
      <div className="flex items-center justify-between">
        <Link to="/" className="text-2xl font-bold bg-gradient-to-r from-neon-blue to-neon-pink bg-clip-text text-transparent animate-glow">
          Gully Premier League
        </Link>
        <div className="flex space-x-6">
          <NavLink to="/" icon={<Trophy size={20} />} text="Home" active={location.pathname === '/'} />
          <NavLink to="/league" icon={<Users size={20} />} text="League" active={location.pathname === '/league'} />
          <NavLink to="/banter/1" icon={<MessageSquare size={20} />} text="Banter" active={location.pathname.startsWith('/banter')} />
          {isAdmin && <NavLink to="/admin" icon={<Shield size={20} />} text="Admin" active={location.pathname === '/admin'} />}
        </div>
      </div>
    </nav>
  );
}

function NavLink({ to, icon, text, active }) {
  return (
    <Link to={to} className={`flex items-center space-x-2 transition-all ${active ? 'text-neon-blue' : 'text-gray-400 hover:text-white'}`}>
      {icon}
      <span>{text}</span>
    </Link>
  );
}