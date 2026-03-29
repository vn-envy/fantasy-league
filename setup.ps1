# PowerShell script to create all files for fantasy-league project

Write-Host "Creating project structure..." -ForegroundColor Green

# Create directories
New-Item -ItemType Directory -Force -Path "src\components", "src\pages", "src\hooks", "src\utils", "netlify\functions" | Out-Null

# ================== Root files ==================

@"
{
  "name": "fantasy-league",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "@supabase/supabase-js": "^2.39.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.20.0",
    "recharts": "^2.10.3",
    "@heroicons/react": "^2.0.18",
    "date-fns": "^2.30.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.37",
    "@types/react-dom": "^18.2.15",
    "@vitejs/plugin-react": "^4.1.0",
    "autoprefixer": "^10.4.16",
    "postcss": "^8.4.31",
    "tailwindcss": "^3.3.5",
    "vite": "^4.5.0"
  }
}
"@ | Out-File -FilePath package.json -Encoding utf8

@"
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/.netlify/functions': 'http://localhost:8888'
    }
  }
})
"@ | Out-File -FilePath vite.config.js -Encoding utf8

@"
/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        'tech-dark': '#0a0f1f',
        'tech-light': '#1a1f2f',
        'neon-blue': '#00f3ff',
        'neon-pink': '#ff00e6',
        'neon-green': '#00ff9d',
      },
      fontFamily: {
        'mono': ['Fira Code', 'monospace'],
      },
      animation: {
        'glow': 'glow 2s ease-in-out infinite alternate',
      },
      keyframes: {
        glow: {
          '0%': { textShadow: '0 0 5px #00f3ff' },
          '100%': { textShadow: '0 0 20px #ff00e6' },
        }
      }
    },
  },
  plugins: [],
}
"@ | Out-File -FilePath tailwind.config.js -Encoding utf8

@"
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
"@ | Out-File -FilePath postcss.config.js -Encoding utf8

@"
[build]
  command = "npm run build"
  functions = "netlify/functions"
  publish = "dist"

[build.environment]
  NODE_VERSION = "18"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[functions]]
  function = "cron"
  schedule = "*/5 * * * *"
"@ | Out-File -FilePath netlify.toml -Encoding utf8

@"
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Gully Premier League</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
"@ | Out-File -FilePath index.html -Encoding utf8

# ================== src/index.css ==================
@"
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  body {
    @apply bg-tech-dark text-white font-mono;
  }
}

@layer components {
  .glass-card {
    @apply bg-tech-light/80 backdrop-blur-sm border border-white/10 rounded-xl shadow-lg;
  }
  .btn-primary {
    @apply px-4 py-2 bg-neon-blue text-tech-dark font-bold rounded-lg hover:bg-neon-pink transition-all duration-300;
  }
  .btn-secondary {
    @apply px-4 py-2 bg-white/10 text-white rounded-lg hover:bg-white/20 transition-all;
  }
}
"@ | Out-File -FilePath src\index.css -Encoding utf8

# ================== src/main.tsx ==================
@"
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
"@ | Out-File -FilePath src\main.tsx -Encoding utf8

# ================== src/App.tsx ==================
@"
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import Landing from './pages/Landing';
import League from './pages/League';
import PickXI from './pages/PickXI';
import MatchCenter from './pages/MatchCenter';
import Banter from './pages/Banter';
import Admin from './pages/Admin';
import { AuthProvider } from './hooks/useAuth';

function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Layout />}>
            <Route index element={<Landing />} />
            <Route path="league" element={<League />} />
            <Route path="pick/:matchId" element={<PickXI />} />
            <Route path="match/:matchId" element={<MatchCenter />} />
            <Route path="banter/:matchId" element={<Banter />} />
            <Route path="admin" element={<Admin />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}

export default App;
"@ | Out-File -FilePath src\App.tsx -Encoding utf8

# ================== src/components/Layout.tsx ==================
@"
import { Outlet } from 'react-router-dom';
import Navbar from './Navbar';

export default function Layout() {
  return (
    <div className="min-h-screen bg-tech-dark">
      <Navbar />
      <main className="container mx-auto px-4 py-8">
        <Outlet />
      </main>
    </div>
  );
}
"@ | Out-File -FilePath src\components\Layout.tsx -Encoding utf8

# ================== src/components/Navbar.tsx ==================
@"
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
"@ | Out-File -FilePath src\components\Navbar.tsx -Encoding utf8

# ================== src/components/PlayerCard.tsx ==================
@"
import { CheckCircle, Crown, Star } from 'lucide-react';

export default function PlayerCard({ player, selected, onToggle, isCaptain, onCaptain, isViceCaptain, onViceCaptain, disabled }) {
  return (
    <div className={`glass-card p-4 transition-all ${selected ? 'border-neon-blue border' : ''}`}>
      <div className="flex justify-between items-start">
        <div>
          <h3 className="text-lg font-bold">{player.name}</h3>
          <p className="text-sm text-gray-400">{player.team_name} • {player.role}</p>
          <p className="text-neon-green mt-1">Credits: {player.credit_value}</p>
        </div>
        <button onClick={onToggle} className={`p-2 rounded-full ${selected ? 'bg-neon-blue text-tech-dark' : 'bg-white/10'}`}>
          {selected ? <CheckCircle size={18} /> : '+'}
        </button>
      </div>
      {selected && (
        <div className="flex gap-2 mt-3">
          <button
            onClick={onCaptain}
            disabled={disabled}
            className={`flex items-center gap-1 px-2 py-1 rounded ${isCaptain ? 'bg-yellow-500 text-tech-dark' : 'bg-white/10'}`}
          >
            <Crown size={14} /> C
          </button>
          <button
            onClick={onViceCaptain}
            disabled={disabled}
            className={`flex items-center gap-1 px-2 py-1 rounded ${isViceCaptain ? 'bg-gray-300 text-tech-dark' : 'bg-white/10'}`}
          >
            <Star size={14} /> VC
          </button>
        </div>
      )}
    </div>
  );
}
"@ | Out-File -FilePath src\components\PlayerCard.tsx -Encoding utf8

# ================== src/components/LeaderboardRow.tsx ==================
@"
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
"@ | Out-File -FilePath src\components\LeaderboardRow.tsx -Encoding utf8

# ================== src/components/ChatMessage.tsx ==================
@"
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
"@ | Out-File -FilePath src\components\ChatMessage.tsx -Encoding utf8

# ================== src/components/CountdownTimer.tsx ==================
@"
import { useState, useEffect } from 'react';

export default function CountdownTimer({ targetDate }) {
  const [timeLeft, setTimeLeft] = useState('');

  useEffect(() => {
    const interval = setInterval(() => {
      const diff = targetDate.getTime() - new Date().getTime();
      if (diff <= 0) {
        setTimeLeft('Match started');
        clearInterval(interval);
        return;
      }
      const hours = Math.floor(diff / (1000 * 60 * 60));
      const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((diff % (1000 * 60)) / 1000);
      setTimeLeft(`${hours}h ${minutes}m ${seconds}s`);
    }, 1000);
    return () => clearInterval(interval);
  }, [targetDate]);

  return <div className="text-3xl font-mono text-neon-blue">{timeLeft}</div>;
}
"@ | Out-File -FilePath src\components\CountdownTimer.tsx -Encoding utf8

# ================== src/components/PointsGraph.tsx ==================
@"
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
"@ | Out-File -FilePath src\components\PointsGraph.tsx -Encoding utf8

# ================== src/pages/Landing.tsx ==================
@"
import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { format } from 'date-fns';
import { Calendar, Clock, TrendingUp, MessageSquare } from 'lucide-react';
import CountdownTimer from '../components/CountdownTimer';
import { useMatches } from '../hooks/useMatches';
import { useLeaderboard } from '../hooks/useLeaderboard';

export default function Landing() {
  const { matches, loading: matchesLoading } = useMatches();
  const { leaderboard, loading: leaderboardLoading } = useLeaderboard(null);
  const [nextMatch, setNextMatch] = useState(null);

  useEffect(() => {
    if (matches && matches.length) {
      const upcoming = matches.find(m => new Date(m.starts_at) > new Date());
      setNextMatch(upcoming);
    }
  }, [matches]);

  if (matchesLoading || leaderboardLoading) return <div className="text-center">Loading...</div>;

  return (
    <div className="space-y-8">
      <div className="glass-card p-8 text-center relative overflow-hidden">
        <div className="absolute inset-0 opacity-10 bg-[url('https://cdn-icons-png.flaticon.com/512/4038/4038677.png')] bg-no-repeat bg-center bg-contain"></div>
        <h1 className="text-5xl font-bold bg-gradient-to-r from-neon-blue via-neon-pink to-neon-green bg-clip-text text-transparent">
          IPL War Room
        </h1>
        <p className="text-xl text-gray-300 mt-4">Your private league. Banter. Bragging rights.</p>
        {nextMatch && (
          <div className="mt-6">
            <div className="text-2xl font-mono">{nextMatch.team_a?.name} vs {nextMatch.team_b?.name}</div>
            <div className="flex justify-center items-center space-x-4 mt-2 text-gray-400">
              <Calendar size={18} /><span>{format(new Date(nextMatch.starts_at), 'dd MMM yyyy')}</span>
              <Clock size={18} /><span>{format(new Date(nextMatch.starts_at), 'hh:mm a')}</span>
            </div>
            <div className="mt-4">
              <CountdownTimer targetDate={new Date(nextMatch.starts_at)} />
            </div>
            <Link to={`/pick/${nextMatch.id}`} className="btn-primary inline-block mt-6">
              Pick Your XI
            </Link>
          </div>
        )}
      </div>

      <div className="glass-card p-6">
        <h2 className="text-2xl font-bold flex items-center gap-2"><TrendingUp className="text-neon-green" /> Top Guns</h2>
        <div className="mt-4 grid grid-cols-1 md:grid-cols-3 gap-4">
          {leaderboard?.slice(0,3).map((entry, idx) => (
            <div key={entry.user_id} className="bg-white/5 rounded-lg p-4 text-center">
              <div className="text-3xl font-bold text-neon-pink">#{idx+1}</div>
              <div className="text-xl mt-2">{entry.display_name}</div>
              <div className="text-2xl font-mono mt-1">{entry.points} pts</div>
            </div>
          ))}
        </div>
      </div>

      <div className="glass-card p-6">
        <h2 className="text-2xl font-bold flex items-center gap-2"><MessageSquare size={24} /> Banter Wall</h2>
        <div className="mt-4 space-y-2">
          <p className="text-gray-400 italic">"Rohit carry job incoming!" - ViratFan</p>
          <p className="text-gray-400 italic">"My captain is gonna smash today" - SKY_22</p>
        </div>
        <Link to="/banter/1" className="text-neon-blue hover:underline mt-2 inline-block">Join the banter →</Link>
      </div>
    </div>
  );
}
"@ | Out-File -FilePath src\pages\Landing.tsx -Encoding utf8

# ================== src/pages/League.tsx ==================
@"
import { useLeaderboard } from '../hooks/useLeaderboard';
import LeaderboardRow from '../components/LeaderboardRow';

export default function League() {
  const { leaderboard, loading } = useLeaderboard(null);

  if (loading) return <div>Loading leaderboard...</div>;

  return (
    <div className="glass-card p-6">
      <h2 className="text-2xl font-bold mb-4">Season Leaderboard</h2>
      <div className="space-y-2">
        {leaderboard?.map((entry, idx) => (
          <LeaderboardRow key={entry.user_id} rank={idx+1} name={entry.display_name} points={entry.points} />
        ))}
      </div>
    </div>
  );
}
"@ | Out-File -FilePath src\pages\League.tsx -Encoding utf8

# ================== src/pages/PickXI.tsx ==================
@"
import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Users, Shield, Star, AlertTriangle } from 'lucide-react';
import { useAuth } from '../hooks/useAuth';
import { api } from '../utils/api';
import PlayerCard from '../components/PlayerCard';

export default function PickXI() {
  const { matchId } = useParams();
  const { user } = useAuth();
  const navigate = useNavigate();
  const [players, setPlayers] = useState([]);
  const [selected, setSelected] = useState([]);
  const [captain, setCaptain] = useState(null);
  const [viceCaptain, setViceCaptain] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchPlayers = async () => {
      const data = await api.get(`players?matchId=${matchId}`);
      setPlayers(data);
      setLoading(false);
    };
    fetchPlayers();
  }, [matchId]);

  const togglePlayer = (playerId) => {
    if (selected.includes(playerId)) {
      setSelected(selected.filter(id => id !== playerId));
      if (captain === playerId) setCaptain(null);
      if (viceCaptain === playerId) setViceCaptain(null);
    } else {
      if (selected.length >= 11) {
        setError('You can only pick 11 players');
        return;
      }
      setSelected([...selected, playerId]);
      setError('');
    }
  };

  const creditsUsed = players
    .filter(p => selected.includes(p.id))
    .reduce((sum, p) => sum + p.credit_value, 0);
  const creditsLeft = 100 - creditsUsed;

  const teamCounts = players
    .filter(p => selected.includes(p.id))
    .reduce((acc, p) => {
      acc[p.team_name] = (acc[p.team_name] || 0) + 1;
      return acc;
    }, {});
  const teamViolation = Object.values(teamCounts).some(count => count > 7);

  const handleSubmit = async () => {
    if (selected.length !== 11) {
      setError('Pick exactly 11 players');
      return;
    }
    if (!captain) {
      setError('Select a captain');
      return;
    }
    if (!viceCaptain) {
      setError('Select a vice-captain');
      return;
    }
    if (teamViolation) {
      setError('Max 7 players from one team');
      return;
    }
    if (creditsLeft < 0) {
      setError('Credits exceeded');
      return;
    }

    try {
      await api.post('entry-save', {
        userId: user.id,
        matchId,
        captainId: captain,
        viceCaptainId: viceCaptain,
        playerIds: selected
      });
      navigate(`/match/${matchId}`);
    } catch (err) {
      setError('Failed to save team');
    }
  };

  if (loading) return <div className="text-center">Loading players...</div>;

  return (
    <div className="space-y-6">
      <div className="glass-card p-6 sticky top-4 z-10">
        <div className="flex flex-wrap justify-between items-center gap-4">
          <div className="flex items-center gap-2"><Users /> Players: {selected.length}/11</div>
          <div className="flex items-center gap-2"><Shield /> Credits: {creditsLeft}/100</div>
          <div className="flex items-center gap-2"><Star /> Captain: {captain ? players.find(p => p.id === captain)?.name : 'Not set'}</div>
          <div className="flex items-center gap-2"><Star /> VC: {viceCaptain ? players.find(p => p.id === viceCaptain)?.name : 'Not set'}</div>
          {teamViolation && <div className="text-red-500 flex items-center gap-1"><AlertTriangle size={16} /> Max 7 per team</div>}
          <button onClick={handleSubmit} className="btn-primary">Lock Team</button>
        </div>
        {error && <div className="text-red-500 mt-2">{error}</div>}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {players.map(player => (
          <PlayerCard
            key={player.id}
            player={player}
            selected={selected.includes(player.id)}
            onToggle={() => togglePlayer(player.id)}
            isCaptain={captain === player.id}
            onCaptain={() => setCaptain(player.id)}
            isViceCaptain={viceCaptain === player.id}
            onViceCaptain={() => setViceCaptain(player.id)}
            disabled={!selected.includes(player.id)}
          />
        ))}
      </div>
    </div>
  );
}
"@ | Out-File -FilePath src\pages\PickXI.tsx -Encoding utf8

# ================== src/pages/MatchCenter.tsx ==================
@"
import { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { TrendingUp, Users, Award } from 'lucide-react';
import { useAuth } from '../hooks/useAuth';
import { useLeaderboard } from '../hooks/useLeaderboard';
import { api } from '../utils/api';
import PointsGraph from '../components/PointsGraph';

export default function MatchCenter() {
  const { matchId } = useParams();
  const { user } = useAuth();
  const [match, setMatch] = useState(null);
  const [myTeam, setMyTeam] = useState(null);
  const { leaderboard, loading } = useLeaderboard(matchId);

  useEffect(() => {
    const fetchData = async () => {
      const matchData = await api.get(`matches?matchId=${matchId}`);
      setMatch(matchData);
      const teamData = await api.get(`entry-my-team?userId=${user.id}&matchId=${matchId}`);
      setMyTeam(teamData);
    };
    fetchData();
    const interval = setInterval(fetchData, 30000);
    return () => clearInterval(interval);
  }, [matchId]);

  if (!match || loading) return <div>Loading match center...</div>;

  return (
    <div className="space-y-6">
      <div className="glass-card p-6 text-center">
        <h1 className="text-3xl font-bold">{match.team_a?.name} vs {match.team_b?.name}</h1>
        <p className="text-gray-400">Status: {match.status}</p>
      </div>

      {myTeam?.exists && (
        <div className="glass-card p-6">
          <h2 className="text-2xl font-bold flex items-center gap-2"><Users /> Your XI</h2>
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-3 mt-4">
            {myTeam.players.map(p => (
              <div key={p.id} className="bg-white/5 p-2 rounded text-center">
                <div className="font-bold">{p.name}</div>
                <div className="text-sm text-neon-green">{p.fantasy_points} pts</div>
              </div>
            ))}
          </div>
          <div className="mt-4 text-xl">Total: {myTeam.entry.total_points} pts</div>
        </div>
      )}

      <div className="glass-card p-6">
        <h2 className="text-2xl font-bold flex items-center gap-2"><TrendingUp /> Live Leaderboard</h2>
        <div className="mt-4 space-y-2">
          {leaderboard?.map((entry, idx) => (
            <div key={entry.user_id} className="flex justify-between items-center p-2 border-b border-white/10">
              <div className="flex items-center gap-2">
                <span className="text-lg font-mono">#{idx+1}</span>
                <span className="font-bold">{entry.display_name}</span>
              </div>
              <div className="text-neon-blue">{entry.points} pts</div>
            </div>
          ))}
        </div>
      </div>

      <div className="glass-card p-6">
        <h2 className="text-2xl font-bold flex items-center gap-2"><Award /> Points Trend</h2>
        <PointsGraph data={leaderboard?.slice(0,5).map(entry => ({ name: entry.display_name, points: entry.points }))} />
      </div>
    </div>
  );
}
"@ | Out-File -FilePath src\pages\MatchCenter.tsx -Encoding utf8

# ================== src/pages/Banter.tsx ==================
@"
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
"@ | Out-File -FilePath src\pages\Banter.tsx -Encoding utf8

# ================== src/pages/Admin.tsx ==================
@"
import { useState } from 'react';
import { api } from '../utils/api';

export default function Admin() {
  const [matchId, setMatchId] = useState('');
  const [status, setStatus] = useState('');

  const recalcPoints = async () => {
    await api.post('admin-recalc', { matchId });
    setStatus('Recalculation triggered');
  };

  const lockMatch = async () => {
    setStatus('Locked (not implemented)');
  };

  return (
    <div className="glass-card p-6">
      <h2 className="text-2xl font-bold mb-4">Admin Panel</h2>
      <div className="space-y-4">
        <div>
          <label className="block text-sm">Match ID</label>
          <input
            type="text"
            value={matchId}
            onChange={(e) => setMatchId(e.target.value)}
            className="bg-white/10 rounded px-3 py-2 w-full"
          />
        </div>
        <div className="flex gap-2">
          <button onClick={recalcPoints} className="btn-primary">Recalc Points</button>
          <button onClick={lockMatch} className="btn-secondary">Force Lock</button>
        </div>
        {status && <div className="text-neon-green">{status}</div>}
      </div>
    </div>
  );
}
"@ | Out-File -FilePath src\pages\Admin.tsx -Encoding utf8

# ================== src/hooks/useAuth.tsx ==================
@"
import { createContext, useContext, useState, useEffect } from 'react';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const stored = localStorage.getItem('user');
    if (stored) setUser(JSON.parse(stored));
    setLoading(false);
  }, []);

  const login = (userData) => {
    setUser(userData);
    localStorage.setItem('user', JSON.stringify(userData));
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem('user');
  };

  return (
    <AuthContext.Provider value={{ user, loading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
"@ | Out-File -FilePath src\hooks\useAuth.tsx -Encoding utf8

# ================== src/hooks/useMatches.ts ==================
@"
import { useState, useEffect } from 'react';
import { api } from '../utils/api';

export function useMatches() {
  const [matches, setMatches] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('matches').then(data => {
      setMatches(data);
      setLoading(false);
    });
  }, []);

  return { matches, loading };
}
"@ | Out-File -FilePath src\hooks\useMatches.ts -Encoding utf8

# ================== src/hooks/useLeaderboard.ts ==================
@"
import { useState, useEffect } from 'react';
import { api } from '../utils/api';

export function useLeaderboard(matchId) {
  const [leaderboard, setLeaderboard] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchLeaderboard = async () => {
      const url = matchId ? `leaderboard?matchId=${matchId}` : 'leaderboard';
      const data = await api.get(url);
      setLeaderboard(data);
      setLoading(false);
    };
    fetchLeaderboard();
    if (matchId) {
      const interval = setInterval(fetchLeaderboard, 30000);
      return () => clearInterval(interval);
    }
  }, [matchId]);

  return { leaderboard, loading };
}
"@ | Out-File -FilePath src\hooks\useLeaderboard.ts -Encoding utf8

# ================== src/utils/api.ts ==================
@"
const BASE_URL = '/.netlify/functions';

export const api = {
  get: async (endpoint) => {
    const res = await fetch(`${BASE_URL}/${endpoint}`);
    if (!res.ok) throw new Error(await res.text());
    return res.json();
  },
  post: async (endpoint, data) => {
    const res = await fetch(`${BASE_URL}/${endpoint}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    if (!res.ok) throw new Error(await res.text());
    return res.json();
  },
};
"@ | Out-File -FilePath src\utils\api.ts -Encoding utf8

# ================== src/utils/pointsCalculator.ts ==================
@"
export const calcPoints = (stats) => {
  let pts = 0;
  pts += stats.in_playing_xi ? 4 : 0;
  pts += stats.runs * 1;
  pts += stats.fours * 1;
  pts += stats.sixes * 2;
  pts += stats.wickets * 25;
  pts += stats.maidens * 8;
  pts += stats.catches * 8;
  pts += stats.stumpings * 12;
  pts += stats.runouts * 12;
  return pts;
};

export const applyMultiplier = (raw, isCaptain, isViceCaptain) => {
  if (isCaptain) return raw * 2;
  if (isViceCaptain) return raw * 1.5;
  return raw;
};
"@ | Out-File -FilePath src\utils\pointsCalculator.ts -Encoding utf8

# ================== Netlify Functions ==================
# league-create.js
@"
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
"@ | Out-File -FilePath netlify\functions\league-create.js -Encoding utf8

# league-join.js
@"
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
"@ | Out-File -FilePath netlify\functions\league-join.js -Encoding utf8

# players.js
@"
const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event) => {
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const { matchId } = event.queryStringParameters;
  if (!matchId) return { statusCode: 400, body: 'matchId required' };

  const { data: match, error: matchError } = await supabase
    .from('matches')
    .select('team_a_id, team_b_id')
    .eq('id', matchId)
    .single();
  if (matchError) return { statusCode: 500, body: JSON.stringify({ error: matchError.message }) };

  const { data: players, error: playersError } = await supabase
    .from('players')
    .select('*, teams!inner(name)')
    .in('team_id', [match.team_a_id, match.team_b_id])
    .eq('is_active', true)
    .order('team_id')
    .order('name');
  if (playersError) return { statusCode: 500, body: JSON.stringify({ error: playersError.message }) };

  const formatted = players.map(p => ({
    ...p,
    team_name: p.teams.name
  }));

  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(formatted)
  };
};
"@ | Out-File -FilePath netlify\functions\players.js -Encoding utf8

# entry-save.js
@"
const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event) => {
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const { userId, matchId, captainId, viceCaptainId, playerIds } = JSON.parse(event.body);

  const { data: match, error: matchError } = await supabase
    .from('matches')
    .select('starts_at')
    .eq('id', matchId)
    .single();
  if (matchError) return { statusCode: 500, body: JSON.stringify({ error: matchError.message }) };
  if (new Date(match.starts_at) <= new Date()) {
    return { statusCode: 403, body: 'Match locked' };
  }

  const { data: players, error: playersError } = await supabase
    .from('players')
    .select('credit_value')
    .in('id', playerIds);
  if (playersError) return { statusCode: 500, body: JSON.stringify({ error: playersError.message }) };
  const creditsUsed = players.reduce((sum, p) => sum + p.credit_value, 0);
  if (creditsUsed > 100) return { statusCode: 400, body: 'Credits exceed 100' };

  const { data: teamCounts, error: teamError } = await supabase
    .from('players')
    .select('team_id')
    .in('id', playerIds);
  if (teamError) return { statusCode: 500, body: JSON.stringify({ error: teamError.message }) };
  const counts = teamCounts.reduce((acc, p) => {
    acc[p.team_id] = (acc[p.team_id] || 0) + 1;
    return acc;
  }, {});
  if (Object.values(counts).some(c => c > 7)) {
    return { statusCode: 400, body: 'Max 7 players per team' };
  }

  const { data: league } = await supabase
    .from('leagues')
    .select('id')
    .limit(1)
    .single();
  const leagueId = league.id;

  const { data: entry, error: entryError } = await supabase
    .from('user_match_entries')
    .insert({
      league_id: leagueId,
      match_id: matchId,
      user_id: userId,
      captain_player_id: captainId,
      vice_captain_player_id: viceCaptainId,
      credits_used: creditsUsed,
      locked_at: new Date().toISOString()
    })
    .select()
    .single();
  if (entryError) return { statusCode: 500, body: JSON.stringify({ error: entryError.message }) };

  const entryPlayers = playerIds.map(pid => ({
    entry_id: entry.id,
    player_id: pid
  }));
  const { error: insertError } = await supabase
    .from('user_match_entry_players')
    .insert(entryPlayers);
  if (insertError) return { statusCode: 500, body: JSON.stringify({ error: insertError.message }) };

  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ entryId: entry.id })
  };
};
"@ | Out-File -FilePath netlify\functions\entry-save.js -Encoding utf8

# entry-my-team.js
@"
const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event) => {
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const { userId, matchId } = event.queryStringParameters;
  if (!userId || !matchId) return { statusCode: 400, body: 'userId and matchId required' };

  const { data: entry, error: entryError } = await supabase
    .from('user_match_entries')
    .select(`
      *,
      captain:captain_player_id(name),
      vice_captain:vice_captain_player_id(name)
    `)
    .eq('user_id', userId)
    .eq('match_id', matchId)
    .maybeSingle();

  if (entryError) return { statusCode: 500, body: JSON.stringify({ error: entryError.message }) };
  if (!entry) {
    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ exists: false })
    };
  }

  const { data: players, error: playersError } = await supabase
    .from('user_match_entry_players')
    .select('player_id')
    .eq('entry_id', entry.id);

  if (playersError) return { statusCode: 500, body: JSON.stringify({ error: playersError.message }) };

  const playerIds = players.map(p => p.player_id);
  const { data: playerDetails, error: detailsError } = await supabase
    .from('players')
    .select('*, teams!inner(name)')
    .in('id', playerIds);
  if (detailsError) return { statusCode: 500, body: JSON.stringify({ error: detailsError.message }) };

  const { data: stats, error: statsError } = await supabase
    .from('player_match_stats')
    .select('player_id, fantasy_points_raw')
    .eq('match_id', matchId)
    .in('player_id', playerIds);
  if (statsError) return { statusCode: 500, body: JSON.stringify({ error: statsError.message }) };

  const statsMap = new Map(stats.map(s => [s.player_id, s.fantasy_points_raw]));

  const enrichedPlayers = playerDetails.map(p => ({
    ...p,
    team_name: p.teams.name,
    fantasy_points: statsMap.get(p.id) || 0
  }));

  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      exists: true,
      entry: {
        ...entry,
        captain_name: entry.captain?.name,
        vice_captain_name: entry.vice_captain?.name
      },
      players: enrichedPlayers
    })
  };
};
"@ | Out-File -FilePath netlify\functions\entry-my-team.js -Encoding utf8

# matches.js
@"
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
      .select(`
        *,
        team_a:team_a_id(name),
        team_b:team_b_id(name)
      `)
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
      .select(`
        *,
        team_a:team_a_id(name),
        team_b:team_b_id(name)
      `)
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
"@ | Out-File -FilePath netlify\functions\matches.js -Encoding utf8

# leaderboard.js
@"
const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event) => {
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const { matchId } = event.queryStringParameters;

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
    const formatted = data.map(entry => ({
      user_id: entry.user_id,
      display_name: entry.users.display_name,
      points: entry.total_points
    }));
    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(formatted)
    };
  } else {
    const { data, error } = await supabase
      .from('user_match_entries')
      .select(`
        user_id,
        total_points,
        users (display_name)
      `);
    if (error) return { statusCode: 500, body: JSON.stringify({ error: error.message }) };
    const totals = data.reduce((acc, entry) => {
      if (!acc[entry.user_id]) {
        acc[entry.user_id] = { user_id: entry.user_id, display_name: entry.users.display_name, points: 0 };
      }
      acc[entry.user_id].points += entry.total_points;
      return acc;
    }, {});
    const leaderboard = Object.values(totals).sort((a, b) => b.points - a.points);
    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(leaderboard)
    };
  }
};
"@ | Out-File -FilePath netlify\functions\leaderboard.js -Encoding utf8

# chat-list.js
@"
const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event) => {
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const { matchId } = event.queryStringParameters;

  let query = supabase
    .from('chat_messages')
    .select(`
      *,
      users (display_name)
    `)
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
"@ | Out-File -FilePath netlify\functions\chat-list.js -Encoding utf8

# chat-post.js
@"
const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event) => {
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const { userId, matchId, message } = JSON.parse(event.body);

  const { data: league } = await supabase
    .from('leagues')
    .select('id')
    .limit(1)
    .single();
  const leagueId = league.id;

  const { error } = await supabase
    .from('chat_messages')
    .insert({
      league_id: leagueId,
      match_id: matchId || null,
      user_id: userId,
      message
    });

  if (error) return { statusCode: 500, body: JSON.stringify({ error: error.message }) };
  return { statusCode: 200, body: 'OK' };
};
"@ | Out-File -FilePath netlify\functions\chat-post.js -Encoding utf8

# admin-recalc.js
@"
const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event) => {
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const { matchId } = JSON.parse(event.body);

  const { data: entries, error: entriesError } = await supabase
    .from('user_match_entries')
    .select('id, captain_player_id, vice_captain_player_id')
    .eq('match_id', matchId);
  if (entriesError) return { statusCode: 500, body: JSON.stringify({ error: entriesError.message }) };

  for (const entry of entries) {
    const { data: entryPlayers, error: playersError } = await supabase
      .from('user_match_entry_players')
      .select('player_id')
      .eq('entry_id', entry.id);
    if (playersError) return { statusCode: 500, body: JSON.stringify({ error: playersError.message }) };

    const playerIds = entryPlayers.map(p => p.player_id);
    const { data: stats, error: statsError } = await supabase
      .from('player_match_stats')
      .select('player_id, fantasy_points_raw')
      .eq('match_id', matchId)
      .in('player_id', playerIds);
    if (statsError) return { statusCode: 500, body: JSON.stringify({ error: statsError.message }) };

    let total = 0;
    for (const stat of stats) {
      let points = stat.fantasy_points_raw;
      if (stat.player_id === entry.captain_player_id) points *= 2;
      else if (stat.player_id === entry.vice_captain_player_id) points *= 1.5;
      total += points;
    }

    await supabase
      .from('user_match_entries')
      .update({ total_points: total })
      .eq('id', entry.id);
  }

  return { statusCode: 200, body: JSON.stringify({ message: 'Recalculation done' }) };
};
"@ | Out-File -FilePath netlify\functions\admin-recalc.js -Encoding utf8

# cron.js
@"
const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event) => {
  if (event.headers['x-netlify-event'] !== 'scheduled') {
    return { statusCode: 404 };
  }

  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const { data: liveMatches, error: matchError } = await supabase
    .from('matches')
    .select('*')
    .eq('status', 'live');
  if (matchError) return { statusCode: 500, body: JSON.stringify({ error: matchError.message }) };

  for (const match of liveMatches) {
    const apiKey = process.env.CRICKET_API_KEY;
    const response = await fetch(
      `https://api.cricketdata.com/v1/match/${match.external_match_id}/stats?apikey=${apiKey}`
    );
    const statsData = await response.json();

    for (const playerStat of statsData.players) {
      const rawPoints = calcPoints(playerStat);
      await supabase
        .from('player_match_stats')
        .upsert({
          match_id: match.id,
          player_id: playerStat.player_id,
          runs: playerStat.runs,
          fours: playerStat.fours,
          sixes: playerStat.sixes,
          wickets: playerStat.wickets,
          maidens: playerStat.maidens,
          catches: playerStat.catches,
          stumpings: playerStat.stumpings,
          runouts: playerStat.runouts,
          in_playing_xi: playerStat.in_playing_xi,
          fantasy_points_raw: rawPoints,
          updated_at: new Date().toISOString()
        }, { onConflict: 'match_id,player_id' });
    }

    await recalcMatchEntries(supabase, match.id);
  }

  return { statusCode: 200 };
};

function calcPoints(stats) {
  let pts = 0;
  pts += stats.in_playing_xi ? 4 : 0;
  pts += stats.runs * 1;
  pts += stats.fours * 1;
  pts += stats.sixes * 2;
  pts += stats.wickets * 25;
  pts += stats.maidens * 8;
  pts += stats.catches * 8;
  pts += stats.stumpings * 12;
  pts += stats.runouts * 12;
  return pts;
}

async function recalcMatchEntries(supabase, matchId) {
  const { data: entries, error } = await supabase
    .from('user_match_entries')
    .select('id, captain_player_id, vice_captain_player_id')
    .eq('match_id', matchId);
  if (error) throw error;

  for (const entry of entries) {
    const { data: entryPlayers, error: playersError } = await supabase
      .from('user_match_entry_players')
      .select('player_id')
      .eq('entry_id', entry.id);
    if (playersError) throw playersError;

    const playerIds = entryPlayers.map(p => p.player_id);
    const { data: stats, error: statsError } = await supabase
      .from('player_match_stats')
      .select('player_id, fantasy_points_raw')
      .eq('match_id', matchId)
      .in('player_id', playerIds);
    if (statsError) throw statsError;

    let total = 0;
    for (const stat of stats) {
      let points = stat.fantasy_points_raw;
      if (stat.player_id === entry.captain_player_id) points *= 2;
      else if (stat.player_id === entry.vice_captain_player_id) points *= 1.5;
      total += points;
    }

    await supabase
      .from('user_match_entries')
      .update({ total_points: total })
      .eq('id', entry.id);
  }
}
"@ | Out-File -FilePath netlify\functions\cron.js -Encoding utf8

Write-Host "All files created successfully!" -ForegroundColor Green
Write-Host "Now run 'npm install' to install dependencies." -ForegroundColor Yellow