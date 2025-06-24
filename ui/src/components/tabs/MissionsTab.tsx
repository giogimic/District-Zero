import React from 'react'
import { useDistrictZeroStore } from '../../store'

export const MissionsTab: React.FC = () => {
  const missions = useDistrictZeroStore((state) => state.missions)
  const currentTeam = useDistrictZeroStore((state) => state.currentTeam)

  const availableMissions = missions.filter(
    (mission) => mission.type === currentTeam && mission.active
  )

  return (
    <div className="h-full overflow-y-auto">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {availableMissions.map((mission) => (
          <div key={mission.id} className="glass p-6 mission-card">
            <div className="flex justify-between items-start mb-4">
              <h3 className="text-xl font-semibold text-white">{mission.title}</h3>
              <span className={`px-2 py-1 rounded text-xs font-medium ${
                mission.type === 'pvp' ? 'bg-neon-pink/20 text-neon-pink' : 'bg-neon-blue/20 text-neon-blue'
              }`}>
                {mission.type.toUpperCase()}
              </span>
            </div>
            
            <p className="text-gray-300 mb-4">{mission.description}</p>
            
            <div className="space-y-3 mb-4">
              <h4 className="text-sm font-medium text-gray-300">Objectives:</h4>
              {mission.objectives.map((objective) => (
                <div key={objective.id} className="flex items-center space-x-3">
                  <div className={`w-3 h-3 rounded-full ${
                    objective.completed ? 'bg-neon-green' : 'bg-gray-600'
                  }`} />
                  <span className="text-sm text-white">{objective.description}</span>
                </div>
              ))}
            </div>
            
            <div className="flex justify-between items-center">
              <span className="text-neon-yellow font-semibold">
                ${mission.reward.toLocaleString()}
              </span>
              <button className="px-4 py-2 bg-neon-green/20 text-neon-green rounded-lg hover:bg-neon-green/30 transition-colors">
                Accept Mission
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
} 