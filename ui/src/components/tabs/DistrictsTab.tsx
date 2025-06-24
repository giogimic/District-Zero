import React from 'react'
import { useDistrictZeroStore } from '../../store'

export const DistrictsTab: React.FC = () => {
  const districts = useDistrictZeroStore((state) => state.districts)
  const currentDistrict = useDistrictZeroStore((state) => state.currentDistrict)

  return (
    <div className="h-full overflow-y-auto">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {districts.map((district) => (
          <div
            key={district.id}
            className={`glass p-6 district-card ${
              currentDistrict?.id === district.id ? 'ring-2 ring-neon-green' : ''
            }`}
          >
            <h3 className="text-xl font-semibold text-white mb-2">{district.name}</h3>
            <p className="text-gray-300 mb-4">{district.description}</p>
            
            <div className="space-y-3">
              <div>
                <div className="flex justify-between text-sm mb-1">
                  <span className="text-gray-400">PvP Influence</span>
                  <span className="text-neon-pink">{district.influence_pvp}%</span>
                </div>
                <div className="progress-bar h-2">
                  <div
                    className="progress-fill pvp"
                    style={{ width: `${district.influence_pvp}%` }}
                  />
                </div>
              </div>
              
              <div>
                <div className="flex justify-between text-sm mb-1">
                  <span className="text-gray-400">PvE Influence</span>
                  <span className="text-neon-blue">{district.influence_pve}%</span>
                </div>
                <div className="progress-bar h-2">
                  <div
                    className="progress-fill pve"
                    style={{ width: `${district.influence_pve}%` }}
                  />
                </div>
              </div>
            </div>
            
            <div className="mt-4 pt-4 border-t border-gray-700">
              <div className="flex justify-between text-sm">
                <span className="text-gray-400">Control Points:</span>
                <span className="text-white">{district.controlPoints?.length || 0}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-400">Last Updated:</span>
                <span className="text-gray-300">
                  {new Date(district.last_updated).toLocaleDateString()}
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
} 