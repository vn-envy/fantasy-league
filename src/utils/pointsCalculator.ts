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
