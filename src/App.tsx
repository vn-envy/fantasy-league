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
