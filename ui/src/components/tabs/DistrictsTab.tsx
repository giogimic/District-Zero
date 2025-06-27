import React, { useState, useEffect } from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/nui';

interface ControlPoint {
  id: string;
  name: string;
  coords: { x: number; y: number; z: number };
  radius: number;
  influence: number;
  currentTeam: 'neutral' | 'pvp' | 'pve';
  captureProgress: number;
  lastCaptured: number;
  isBeingCaptured: boolean;
  capturingTeam?: 'pvp' | 'pve';
  captureStartTime: number;
}

interface DistrictInfluence {
  pvp: number;
  pve: number;
}

interface District {
  id: string;
  name: string;
  coords: { x: number; y: number; z: number };
  radius: number;
  controlPoints: ControlPoint[];
  influence: DistrictInfluence;
  lastCaptured: number;
  controllingTeam: 'neutral' | 'pvp' | 'pve';
}

interface DistrictsTabProps {
  isVisible: boolean;
}

const DistrictsTab: React.FC<DistrictsTabProps> = ({ isVisible }) => {
  const [districts, setDistricts] = useState<District[]>([]);
  const [currentDistrict, setCurrentDistrict] = useState<District | null>(null);
  const [controlPoints, setControlPoints] = useState<ControlPoint[]>([]);
  const [districtInfluence, setDistrictInfluence] = useState<DistrictInfluence>({ pvp: 0, pve: 0 });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // NUI Event handlers
  useNuiEvent('districtEntered', (district: District) => {
    setCurrentDistrict(district);
    setControlPoints(district.controlPoints || []);
    setDistrictInfluence(district.influence || { pvp: 0, pve: 0 });
  });

  useNuiEvent('districtLeft', () => {
    setCurrentDistrict(null);
    setControlPoints([]);
    setDistrictInfluence({ pvp: 0, pve: 0 });
  });

  useNuiEvent('controlPointUpdate', (data: { districtId: string; pointId: string; point: ControlPoint }) => {
    setControlPoints(prev => 
      prev.map(point => 
        point.id === data.pointId ? data.point : point
      )
    );
  });

  useNuiEvent('districtInfluenceUpdate', (data: { districtId: string; influence: DistrictInfluence }) => {
    if (currentDistrict && currentDistrict.id === data.districtId) {
      setDistrictInfluence(data.influence);
    }
  });

  // Load districts on component mount
  useEffect(() => {
    if (isVisible) {
      loadDistricts();
    }
  }, [isVisible]);

  const loadDistricts = async () => {
    setLoading(true);
    setError(null);
    
    try {
      const response = await fetchNui<District[]>('getDistricts');
      setDistricts(response || []);
    } catch (err) {
      setError('Failed to load districts');
      console.error('Error loading districts:', err);
    } finally {
      setLoading(false);
    }
  };

  const getTeamColor = (team: string) => {
    switch (team) {
      case 'pvp': return 'text-red-500';
      case 'pve': return 'text-blue-500';
      default: return 'text-gray-500';
    }
  };

  const getTeamBgColor = (team: string) => {
    switch (team) {
      case 'pvp': return 'bg-red-500/20 border-red-500/50';
      case 'pve': return 'bg-blue-500/20 border-blue-500/50';
      default: return 'bg-gray-500/20 border-gray-500/50';
    }
  };

  const getInfluenceBarColor = (team: 'pvp' | 'pve') => {
    return team === 'pvp' ? 'bg-red-500' : 'bg-blue-500';
  };

  const formatTime = (timestamp: number) => {
    if (!timestamp) return 'Never';
    const date = new Date(timestamp);
    return date.toLocaleTimeString();
  };

  const handleCapturePoint = async (pointId: string) => {
    if (!currentDistrict) return;
    
    try {
      await fetchNui('startCapture', {
        districtId: currentDistrict.id,
        pointId: pointId
      });
    } catch (err) {
      console.error('Error starting capture:', err);
    }
  };

  const handleTeleportToPoint = async (point: ControlPoint) => {
    try {
      await fetchNui('teleportToPoint', {
        coords: point.coords
      });
    } catch (err) {
      console.error('Error teleporting to point:', err);
    }
  };

  if (!isVisible) return null;

  return (
    <div className="h-full flex flex-col space-y-4 p-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-white">District Control</h2>
        <button
          onClick={loadDistricts}
          disabled={loading}
          className="px-4 py-2 bg-blue-600 hover:bg-blue-700 disabled:bg-blue-800 text-white rounded-lg transition-colors"
        >
          {loading ? 'Loading...' : 'Refresh'}
        </button>
      </div>

      {error && (
        <div className="bg-red-500/20 border border-red-500/50 text-red-300 p-3 rounded-lg">
          {error}
        </div>
      )}

      {/* Current District Status */}
      {currentDistrict && (
        <div className="bg-gray-800/50 border border-gray-700 rounded-lg p-4">
          <h3 className="text-xl font-semibold text-white mb-3">
            Current District: {currentDistrict.name}
          </h3>
          
          {/* Influence Display */}
          <div className="mb-4">
            <div className="flex justify-between text-sm text-gray-300 mb-2">
              <span>PvP Influence: {districtInfluence.pvp}%</span>
              <span>PvE Influence: {districtInfluence.pve}%</span>
            </div>
            <div className="w-full bg-gray-700 rounded-full h-3">
              <div 
                className={`h-3 rounded-full ${getInfluenceBarColor('pvp')}`}
                style={{ width: `${districtInfluence.pvp}%` }}
              />
              <div 
                className={`h-3 rounded-full ${getInfluenceBarColor('pve')} -mt-3`}
                style={{ width: `${districtInfluence.pve}%`, marginLeft: `${districtInfluence.pvp}%` }}
              />
            </div>
          </div>

          {/* Controlling Team */}
          <div className={`inline-block px-3 py-1 rounded-full text-sm font-medium ${getTeamBgColor(currentDistrict.controllingTeam)}`}>
            Controlling Team: {currentDistrict.controllingTeam.toUpperCase()}
          </div>
        </div>
      )}

      {/* Control Points */}
      {currentDistrict && controlPoints.length > 0 && (
        <div className="flex-1 overflow-y-auto">
          <h3 className="text-lg font-semibold text-white mb-3">Control Points</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {controlPoints.map((point) => (
              <div 
                key={point.id}
                className={`bg-gray-800/50 border rounded-lg p-4 ${getTeamBgColor(point.currentTeam)}`}
              >
                <div className="flex items-center justify-between mb-3">
                  <h4 className="text-lg font-medium text-white">{point.name}</h4>
                  <span className={`px-2 py-1 rounded text-xs font-medium ${getTeamColor(point.currentTeam)}`}>
                    {point.currentTeam.toUpperCase()}
                  </span>
                </div>

                {/* Capture Progress */}
                {point.isBeingCaptured && (
                  <div className="mb-3">
                    <div className="flex justify-between text-sm text-gray-300 mb-1">
                      <span>Capturing: {point.capturingTeam?.toUpperCase()}</span>
                      <span>{Math.round(point.captureProgress)}%</span>
                    </div>
                    <div className="w-full bg-gray-700 rounded-full h-2">
                      <div 
                        className={`h-2 rounded-full ${getInfluenceBarColor(point.capturingTeam || 'pvp')}`}
                        style={{ width: `${point.captureProgress}%` }}
                      />
                    </div>
                  </div>
                )}

                {/* Point Info */}
                <div className="space-y-2 text-sm text-gray-300">
                  <div>Influence: {point.influence}%</div>
                  <div>Radius: {point.radius}m</div>
                  <div>Last Captured: {formatTime(point.lastCaptured)}</div>
                </div>

                {/* Actions */}
                <div className="flex space-x-2 mt-3">
                  <button
                    onClick={() => handleTeleportToPoint(point)}
                    className="flex-1 px-3 py-2 bg-green-600 hover:bg-green-700 text-white rounded text-sm transition-colors"
                  >
                    Teleport
                  </button>
                  {!point.isBeingCaptured && point.currentTeam !== 'neutral' && (
                    <button
                      onClick={() => handleCapturePoint(point.id)}
                      className="flex-1 px-3 py-2 bg-yellow-600 hover:bg-yellow-700 text-white rounded text-sm transition-colors"
                    >
                      Capture
                    </button>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* All Districts List */}
      {!currentDistrict && (
        <div className="flex-1 overflow-y-auto">
          <h3 className="text-lg font-semibold text-white mb-3">Available Districts</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {districts.map((district) => (
              <div 
                key={district.id}
                className="bg-gray-800/50 border border-gray-700 rounded-lg p-4 hover:bg-gray-800/70 transition-colors cursor-pointer"
                onClick={() => {
                  setCurrentDistrict(district);
                  setControlPoints(district.controlPoints || []);
                  setDistrictInfluence(district.influence || { pvp: 0, pve: 0 });
                }}
              >
                <div className="flex items-center justify-between mb-3">
                  <h4 className="text-lg font-medium text-white">{district.name}</h4>
                  <span className={`px-2 py-1 rounded text-xs font-medium ${getTeamColor(district.controllingTeam)}`}>
                    {district.controllingTeam.toUpperCase()}
                  </span>
                </div>

                <div className="space-y-2 text-sm text-gray-300">
                  <div>Control Points: {district.controlPoints?.length || 0}</div>
                  <div>PvP Influence: {district.influence?.pvp || 0}%</div>
                  <div>PvE Influence: {district.influence?.pve || 0}%</div>
                </div>

                <div className="mt-3 text-xs text-gray-400">
                  Click to view details
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* No Districts Message */}
      {!currentDistrict && districts.length === 0 && !loading && (
        <div className="flex-1 flex items-center justify-center">
          <div className="text-center text-gray-400">
            <div className="text-4xl mb-4">🏙️</div>
            <div className="text-lg">No districts available</div>
            <div className="text-sm">Districts will appear here when you're near them</div>
          </div>
        </div>
      )}

      {/* Loading State */}
      {loading && (
        <div className="flex-1 flex items-center justify-center">
          <div className="text-center text-gray-400">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500 mx-auto mb-4"></div>
            <div>Loading districts...</div>
          </div>
        </div>
      )}
    </div>
  );
};

export default DistrictsTab; 