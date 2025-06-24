import React from 'react'
import { useDistrictZeroStore } from '../../store'

export const TeamsTab: React.FC = () => {
  const teams = useDistrictZeroStore((state) => state.teams)
  const currentTeam = useDistrictZeroStore((state) => state.currentTeam)
  const teamBalance = useDistrictZeroStore((state) => state.teamBalance)

  return (
    <div className="h-full overflow-y-auto space-y-6">
      {/* Team Selection */}
      <div className="glass p-6">
        <h3 className="text-xl font-semibold text-white mb-4">Select Team</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {teams.map((team) => (
            <div
              key={team.id}
              className={`p-6 rounded-lg border-2 transition-all ${
                currentTeam === team.id
                  ? 'border-neon-green bg-neon-green/10'
                  : 'border-gray-600 hover:border-gray-400'
              }`}
            >
              <h4 className="text-lg font-semibold text-white mb-2">{team.name}</h4>
              <p className="text-gray-300 mb-4">{team.description}</p>
              <div className="flex justify-between items-center">
                <span className="text-sm text-gray-400">Members: {team.members}</span>
                <span className="text-sm text-gray-400">Influence: {team.influence}%</span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Team Balance */}
      {teamBalance && (
        <div className="glass p-6">
          <h3 className="text-xl font-semibold text-white mb-4">Team Balance</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <h4 className="text-lg font-medium text-neon-pink mb-3">PvP Team</h4>
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span className="text-gray-300">Members:</span>
                  <span className="text-neon-pink">{teamBalance.pvp.members}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-300">Influence:</span>
                  <span className="text-neon-pink">{teamBalance.pvp.influence}%</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-300">Districts Controlled:</span>
                  <span className="text-neon-pink">{teamBalance.pvp.districts_controlled}</span>
                </div>
              </div>
            </div>
            
            <div>
              <h4 className="text-lg font-medium text-neon-blue mb-3">PvE Team</h4>
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span className="text-gray-300">Members:</span>
                  <span className="text-neon-blue">{teamBalance.pve.members}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-300">Influence:</span>
                  <span className="text-neon-blue">{teamBalance.pve.influence}%</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-300">Districts Controlled:</span>
                  <span className="text-neon-blue">{teamBalance.pve.districts_controlled}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
} 