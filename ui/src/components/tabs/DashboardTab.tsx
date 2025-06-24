import React from 'react'
import { useDistrictZeroStore } from '../../store'

export const DashboardTab: React.FC = () => {
  const currentDistrict = useDistrictZeroStore((state) => state.currentDistrict)
  const currentTeam = useDistrictZeroStore((state) => state.currentTeam)
  const currentMission = useDistrictZeroStore((state) => state.currentMission)
  const playerStats = useDistrictZeroStore((state) => state.playerStats)
  const teamBalance = useDistrictZeroStore((state) => state.teamBalance)

  return (
    <div className="h-full overflow-y-auto space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {/* Current Status */}
        <div className="glass p-6">
          <h3 className="text-xl font-semibold text-white mb-4">Current Status</h3>
          <div className="space-y-3">
            <div className="flex justify-between">
              <span className="text-gray-300">District:</span>
              <span className="text-white font-medium">
                {currentDistrict?.name || 'None'}
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-300">Team:</span>
              <span className="text-white font-medium">
                {currentTeam ? currentTeam.toUpperCase() : 'None'}
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-300">Mission:</span>
              <span className="text-white font-medium">
                {currentMission?.title || 'None'}
              </span>
            </div>
          </div>
        </div>

        {/* Player Stats */}
        <div className="glass p-6">
          <h3 className="text-xl font-semibold text-white mb-4">Player Stats</h3>
          {playerStats ? (
            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="text-gray-300">Missions Completed:</span>
                <span className="text-neon-green">{playerStats.missions_completed}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-300">Total Rewards:</span>
                <span className="text-neon-yellow">${playerStats.total_rewards.toLocaleString()}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-300">Playtime:</span>
                <span className="text-neon-blue">{playerStats.playtime_hours}h</span>
              </div>
            </div>
          ) : (
            <p className="text-gray-400">No stats available</p>
          )}
        </div>

        {/* Team Balance */}
        <div className="glass p-6">
          <h3 className="text-xl font-semibold text-white mb-4">Team Balance</h3>
          {teamBalance ? (
            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="text-gray-300">PvP Members:</span>
                <span className="text-neon-pink">{teamBalance.pvp.members}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-300">PvE Members:</span>
                <span className="text-neon-blue">{teamBalance.pve.members}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-300">PvP Influence:</span>
                <span className="text-neon-pink">{teamBalance.pvp.influence}%</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-300">PvE Influence:</span>
                <span className="text-neon-blue">{teamBalance.pve.influence}%</span>
              </div>
            </div>
          ) : (
            <p className="text-gray-400">No balance data available</p>
          )}
        </div>
      </div>

      {/* Current Mission Progress */}
      {currentMission && (
        <div className="glass p-6">
          <h3 className="text-xl font-semibold text-white mb-4">Current Mission</h3>
          <div className="space-y-4">
            <div>
              <h4 className="text-lg font-medium text-white">{currentMission.title}</h4>
              <p className="text-gray-300">{currentMission.description}</p>
            </div>
            <div className="space-y-2">
              <h5 className="text-sm font-medium text-gray-300">Objectives:</h5>
              {currentMission.objectives.map((objective) => (
                <div
                  key={objective.id}
                  className={`flex items-center space-x-3 p-3 rounded-lg ${
                    objective.completed ? 'bg-neon-green/20' : 'bg-gray-800/50'
                  }`}
                >
                  <div
                    className={`w-4 h-4 rounded-full border-2 ${
                      objective.completed
                        ? 'bg-neon-green border-neon-green'
                        : 'border-gray-400'
                    }`}
                  />
                  <span className="text-white">{objective.description}</span>
                  {!objective.completed && (
                    <span className="text-sm text-gray-400 ml-auto">
                      {objective.progress}/{objective.max_progress}
                    </span>
                  )}
                </div>
              ))}
            </div>
            <div className="flex justify-between items-center">
              <span className="text-gray-300">Reward:</span>
              <span className="text-neon-yellow font-semibold">
                ${currentMission.reward.toLocaleString()}
              </span>
            </div>
          </div>
        </div>
      )}

      {/* Quick Actions */}
      <div className="glass p-6">
        <h3 className="text-xl font-semibold text-white mb-4">Quick Actions</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <button className="p-4 bg-neon-green/20 text-neon-green rounded-lg hover:bg-neon-green/30 transition-colors">
            View Districts
          </button>
          <button className="p-4 bg-neon-blue/20 text-neon-blue rounded-lg hover:bg-neon-blue/30 transition-colors">
            Browse Missions
          </button>
          <button className="p-4 bg-neon-purple/20 text-neon-purple rounded-lg hover:bg-neon-purple/30 transition-colors">
            Team Info
          </button>
          <button className="p-4 bg-neon-orange/20 text-neon-orange rounded-lg hover:bg-neon-orange/30 transition-colors">
            Settings
          </button>
        </div>
      </div>
    </div>
  )
} 