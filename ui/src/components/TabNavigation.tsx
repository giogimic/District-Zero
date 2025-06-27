import React from 'react'
import { motion } from 'framer-motion'
import { useDistrictZeroStore } from '../store'
import type { UITab } from '../types'

const tabs: Array<{ id: UITab; label: string; icon: string }> = [
  { id: 'dashboard', label: 'Dashboard', icon: '📊' },
  { id: 'districts', label: 'Districts', icon: '🗺️' },
  { id: 'missions', label: 'Missions', icon: '🎯' },
  { id: 'teams', label: 'Teams', icon: '👥' },
  { id: 'analytics', label: 'Analytics', icon: '📈' },
  { id: 'settings', label: 'Settings', icon: '⚙️' },
]

export const TabNavigation: React.FC = () => {
  const currentTab = useDistrictZeroStore((state) => state.currentTab)
  const setCurrentTab = useDistrictZeroStore((state) => state.setCurrentTab)

  return (
    <div className="flex space-x-1 mb-6">
      {tabs.map((tab) => (
        <motion.button
          key={tab.id}
          onClick={() => setCurrentTab(tab.id)}
          className={`flex items-center space-x-2 px-4 py-2 rounded-lg font-medium transition-all duration-200 ${
            currentTab === tab.id
              ? 'bg-neon-green/20 text-neon-green neon-glow'
              : 'text-gray-300 hover:text-white hover:bg-white/10'
          }`}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          <span className="text-lg">{tab.icon}</span>
          <span>{tab.label}</span>
        </motion.button>
      ))}
    </div>
  )
} 