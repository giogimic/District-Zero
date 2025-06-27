import React, { useState, useEffect } from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/nui';

interface MissionObjective {
  type: string;
  target: number;
  current: number;
  description: string;
  reward: number;
}

interface Mission {
  id: string;
  type: string;
  difficulty: string;
  districtId: string;
  objectives: MissionObjective;
  startTime: number;
  timeLimit: number;
  status: 'active' | 'completed' | 'failed';
  progress: number;
  rewards: {
    money: number;
    exp: number;
    items: any[];
  };
  completionTime?: number;
  failReason?: string;
  failTime?: number;
}

interface MissionStats {
  totalMissions: number;
  completedMissions: number;
  failedMissions: number;
  totalRewards: number;
  totalExp: number;
}

interface AvailableMission {
  type: string;
  difficulty: string;
  districtId: string;
  objectives: MissionObjective;
}

interface MissionsTabProps {
  isVisible: boolean;
}

const MissionsTab: React.FC<MissionsTabProps> = ({ isVisible }) => {
  const [activeMissions, setActiveMissions] = useState<Mission[]>([]);
  const [availableMissions, setAvailableMissions] = useState<AvailableMission[]>([]);
  const [missionStats, setMissionStats] = useState<MissionStats>({
    totalMissions: 0,
    completedMissions: 0,
    failedMissions: 0,
    totalRewards: 0,
    totalExp: 0
  });
  const [selectedDistrict, setSelectedDistrict] = useState<string>('downtown');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showCreateMission, setShowCreateMission] = useState(false);

  // NUI Event handlers
  useNuiEvent('missionCreated', (data: any) => {
    const mission = data as Mission;
    setActiveMissions(prev => [...prev, mission]);
    setShowCreateMission(false);
  });

  useNuiEvent('missionProgress', (data: any) => {
    const progressData = data as { missionId: string; progress: number; objectiveType: string };
    setActiveMissions(prev => 
      prev.map(mission => 
        mission.id === progressData.missionId 
          ? { ...mission, progress: progressData.progress }
          : mission
      )
    );
  });

  useNuiEvent('missionCompleted', (data: any) => {
    const missionId = data as string;
    setActiveMissions(prev => prev.filter(mission => mission.id !== missionId));
    loadMissionStats();
  });

  useNuiEvent('missionFailed', (data: any) => {
    const failData = data as { missionId: string; reason: string };
    setActiveMissions(prev => prev.filter(mission => mission.id !== failData.missionId));
    loadMissionStats();
  });

  // Load data on component mount
  useEffect(() => {
    if (isVisible) {
      loadPlayerMissions();
      loadAvailableMissions();
    }
  }, [isVisible, selectedDistrict]);

  const loadPlayerMissions = async () => {
    setLoading(true);
    setError(null);
    
    try {
      const response = await fetchNui<{ activeMissions: Mission[]; stats: MissionStats }>('getPlayerMissions');
      if (response) {
        setActiveMissions(response.activeMissions || []);
        setMissionStats(response.stats || {
          totalMissions: 0,
          completedMissions: 0,
          failedMissions: 0,
          totalRewards: 0,
          totalExp: 0
        });
      }
    } catch (err) {
      setError('Failed to load missions');
      console.error('Error loading missions:', err);
    } finally {
      setLoading(false);
    }
  };

  const loadAvailableMissions = async () => {
    try {
      const response = await fetchNui<AvailableMission[]>('getAvailableMissions', { districtId: selectedDistrict });
      setAvailableMissions(response || []);
    } catch (err) {
      console.error('Error loading available missions:', err);
    }
  };

  const loadMissionStats = async () => {
    try {
      const response = await fetchNui<{ activeMissions: Mission[]; stats: MissionStats }>('getPlayerMissions');
      if (response) {
        setMissionStats(response.stats || {
          totalMissions: 0,
          completedMissions: 0,
          failedMissions: 0,
          totalRewards: 0,
          totalExp: 0
        });
      }
    } catch (err) {
      console.error('Error loading mission stats:', err);
    }
  };

  const handleCreateMission = async (missionType: string, difficulty: string) => {
    try {
      const response = await fetchNui('createMission', {
        missionType,
        difficulty,
        districtId: selectedDistrict
      });
      
      if (response.success) {
        setShowCreateMission(false);
        loadPlayerMissions();
      } else {
        setError(response.error || 'Failed to create mission');
      }
    } catch (err) {
      setError('Failed to create mission');
      console.error('Error creating mission:', err);
    }
  };

  const getMissionTypeIcon = (type: string) => {
    switch (type) {
      case 'capture_points': return '🎯';
      case 'defend_points': return '🛡️';
      case 'eliminate_players': return '⚔️';
      case 'survive_time': return '⏱️';
      default: return '📋';
    }
  };

  const getDifficultyColor = (difficulty: string) => {
    switch (difficulty) {
      case 'EASY': return 'text-green-500';
      case 'MEDIUM': return 'text-yellow-500';
      case 'HARD': return 'text-red-500';
      default: return 'text-gray-500';
    }
  };

  const getDifficultyBgColor = (difficulty: string) => {
    switch (difficulty) {
      case 'EASY': return 'bg-green-500/20 border-green-500/50';
      case 'MEDIUM': return 'bg-yellow-500/20 border-yellow-500/50';
      case 'HARD': return 'bg-red-500/20 border-red-500/50';
      default: return 'bg-gray-500/20 border-gray-500/50';
    }
  };

  const formatTime = (timestamp: number) => {
    if (!timestamp) return 'Never';
    const date = new Date(timestamp);
    return date.toLocaleTimeString();
  };

  const formatDuration = (milliseconds: number) => {
    const seconds = Math.floor(milliseconds / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    
    if (hours > 0) {
      return `${hours}h ${minutes % 60}m`;
    } else if (minutes > 0) {
      return `${minutes}m ${seconds % 60}s`;
    } else {
      return `${seconds}s`;
    }
  };

  const getRemainingTime = (mission: Mission) => {
    const elapsed = Date.now() - mission.startTime;
    const remaining = mission.timeLimit - elapsed;
    return Math.max(0, remaining);
  };

  if (!isVisible) return null;

  return (
    <div className="h-full flex flex-col space-y-4 p-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-white">Missions</h2>
        <button
          onClick={() => setShowCreateMission(true)}
          disabled={loading}
          className="px-4 py-2 bg-blue-600 hover:bg-blue-700 disabled:bg-blue-800 text-white rounded-lg transition-colors"
        >
          Create Mission
        </button>
      </div>

      {error && (
        <div className="bg-red-500/20 border border-red-500/50 text-red-300 p-3 rounded-lg">
          {error}
        </div>
      )}

      {/* Mission Statistics */}
      <div className="bg-gray-800/50 border border-gray-700 rounded-lg p-4">
        <h3 className="text-lg font-semibold text-white mb-3">Mission Statistics</h3>
        <div className="grid grid-cols-2 md:grid-cols-5 gap-4 text-sm">
          <div className="text-center">
            <div className="text-2xl font-bold text-blue-500">{missionStats.totalMissions}</div>
            <div className="text-gray-400">Total Missions</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-green-500">{missionStats.completedMissions}</div>
            <div className="text-gray-400">Completed</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-red-500">{missionStats.failedMissions}</div>
            <div className="text-gray-400">Failed</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-yellow-500">${missionStats.totalRewards.toLocaleString()}</div>
            <div className="text-gray-400">Total Rewards</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-purple-500">{missionStats.totalExp.toLocaleString()}</div>
            <div className="text-gray-400">Total EXP</div>
          </div>
        </div>
      </div>

      {/* Active Missions */}
      {activeMissions.length > 0 && (
        <div className="flex-1 overflow-y-auto">
          <h3 className="text-lg font-semibold text-white mb-3">Active Missions</h3>
          <div className="space-y-4">
            {activeMissions.map((mission) => (
              <div 
                key={mission.id}
                className={`bg-gray-800/50 border rounded-lg p-4 ${getDifficultyBgColor(mission.difficulty)}`}
              >
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center space-x-3">
                    <span className="text-2xl">{getMissionTypeIcon(mission.type)}</span>
                    <div>
                      <h4 className="text-lg font-medium text-white">
                        {mission.objectives.description}
                      </h4>
                      <div className="flex items-center space-x-2 text-sm">
                        <span className={`px-2 py-1 rounded ${getDifficultyColor(mission.difficulty)}`}>
                          {mission.difficulty}
              </span>
                        <span className="text-gray-400">•</span>
                        <span className="text-gray-400">{mission.districtId}</span>
                      </div>
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="text-sm text-gray-400">Progress</div>
                    <div className="text-lg font-bold text-white">{Math.round(mission.progress)}%</div>
                  </div>
                </div>

                {/* Progress Bar */}
                <div className="mb-3">
                  <div className="w-full bg-gray-700 rounded-full h-2">
                    <div 
                      className="bg-blue-500 h-2 rounded-full transition-all duration-300"
                      style={{ width: `${mission.progress}%` }}
                    />
                  </div>
            </div>
            
                {/* Mission Details */}
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                  <div>
                    <div className="text-gray-400">Objective</div>
                    <div className="text-white">
                      {mission.objectives.current} / {mission.objectives.target}
                    </div>
                  </div>
                  <div>
                    <div className="text-gray-400">Time Remaining</div>
                    <div className="text-white">
                      {formatDuration(getRemainingTime(mission))}
                    </div>
                  </div>
                  <div>
                    <div className="text-gray-400">Reward</div>
                    <div className="text-white">
                      ${mission.rewards.money} + {mission.rewards.exp} EXP
                    </div>
                  </div>
                  <div>
                    <div className="text-gray-400">Started</div>
                    <div className="text-white">
                      {formatTime(mission.startTime)}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Available Missions */}
      {!showCreateMission && availableMissions.length > 0 && (
        <div className="flex-1 overflow-y-auto">
          <div className="flex items-center justify-between mb-3">
            <h3 className="text-lg font-semibold text-white">Available Missions</h3>
            <select
              value={selectedDistrict}
              onChange={(e) => setSelectedDistrict(e.target.value)}
              className="px-3 py-1 bg-gray-700 text-white rounded border border-gray-600"
              aria-label="Select district for available missions"
            >
              <option value="downtown">Downtown</option>
              <option value="industrial">Industrial</option>
              <option value="residential">Residential</option>
              <option value="entertainment">Entertainment</option>
              <option value="waterfront">Waterfront</option>
            </select>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {availableMissions.map((mission, index) => (
              <div 
                key={index}
                className={`bg-gray-800/50 border rounded-lg p-4 ${getDifficultyBgColor(mission.difficulty)} hover:bg-gray-800/70 transition-colors cursor-pointer`}
                onClick={() => handleCreateMission(mission.type, mission.difficulty)}
              >
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center space-x-3">
                    <span className="text-2xl">{getMissionTypeIcon(mission.type)}</span>
                    <div>
                      <h4 className="text-lg font-medium text-white">
                        {mission.objectives.description}
                      </h4>
                      <span className={`px-2 py-1 rounded text-xs ${getDifficultyColor(mission.difficulty)}`}>
                        {mission.difficulty}
                      </span>
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="text-sm text-gray-400">Reward</div>
                    <div className="text-lg font-bold text-white">${mission.objectives.reward}</div>
                  </div>
                </div>
                <div className="text-sm text-gray-400">
                  Click to start this mission
                </div>
                </div>
              ))}
            </div>
        </div>
      )}

      {/* Create Mission Modal */}
      {showCreateMission && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-gray-800 border border-gray-700 rounded-lg p-6 max-w-md w-full mx-4">
            <h3 className="text-xl font-semibold text-white mb-4">Create New Mission</h3>
            
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">District</label>
                <select
                  value={selectedDistrict}
                  onChange={(e) => setSelectedDistrict(e.target.value)}
                  className="w-full px-3 py-2 bg-gray-700 text-white rounded border border-gray-600"
                  aria-label="Select district for new mission"
                >
                  <option value="downtown">Downtown</option>
                  <option value="industrial">Industrial</option>
                  <option value="residential">Residential</option>
                  <option value="entertainment">Entertainment</option>
                  <option value="waterfront">Waterfront</option>
                </select>
              </div>
              
              <div className="flex space-x-2">
                <button
                  onClick={() => setShowCreateMission(false)}
                  className="flex-1 px-4 py-2 bg-gray-600 hover:bg-gray-700 text-white rounded transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={() => loadAvailableMissions()}
                  className="flex-1 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded transition-colors"
                >
                  Continue
              </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* No Missions Message */}
      {activeMissions.length === 0 && availableMissions.length === 0 && !loading && !showCreateMission && (
        <div className="flex-1 flex items-center justify-center">
          <div className="text-center text-gray-400">
            <div className="text-4xl mb-4">📋</div>
            <div className="text-lg">No missions available</div>
            <div className="text-sm">Join a team and visit a district to see available missions</div>
          </div>
        </div>
      )}

      {/* Loading State */}
      {loading && (
        <div className="flex-1 flex items-center justify-center">
          <div className="text-center text-gray-400">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500 mx-auto mb-4"></div>
            <div>Loading missions...</div>
          </div>
      </div>
      )}
    </div>
  );
};

export default MissionsTab; 