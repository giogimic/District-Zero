import React from 'react'
import { motion } from 'framer-motion'
import { useDistrictZeroStore } from '../store'
import { nuiActions } from '../utils/nui'

interface TeamSelectionModalProps {
  district: any
  onClose: () => void
}

export const TeamSelectionModal: React.FC<TeamSelectionModalProps> = ({ district, onClose }) => {
  const teams = useDistrictZeroStore((state) => state.teams)

  const handleTeamSelect = async (team: 'pvp' | 'pve') => {
    try {
      const response = await nuiActions.selectTeam(team)
      if (response.success) {
        onClose()
      } else {
        console.error('Failed to select team:', response.error)
      }
    } catch (error) {
      console.error('Error selecting team:', error)
    }
  }

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm"
    >
      <motion.div
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        exit={{ scale: 0.9, opacity: 0 }}
        transition={{ duration: 0.3, ease: 'easeOut' }}
        className="glass p-8 max-w-md w-full mx-4"
      >
        <div className="text-center mb-6">
          <h2 className="text-2xl font-bold text-white mb-2">Welcome to {district.name}</h2>
          <p className="text-gray-300">Select your team to begin missions in this district</p>
        </div>

        <div className="space-y-4">
          {/* PvP Team */}
          <motion.div
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            className="p-6 border-2 border-neon-pink/50 rounded-lg hover:border-neon-pink transition-colors cursor-pointer"
            onClick={() => handleTeamSelect('pvp')}
          >
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-xl font-semibold text-neon-pink">PvP Team</h3>
              <div className="w-8 h-8 rounded-full bg-neon-pink/20 flex items-center justify-center">
                <span className="text-neon-pink text-sm font-bold">P</span>
              </div>
            </div>
            <p className="text-gray-300 text-sm mb-3">
              Fight against other players for control of districts. Engage in competitive combat and strategic gameplay.
            </p>
            <div className="flex justify-between text-xs text-gray-400">
              <span>Competitive</span>
              <span>Player vs Player</span>
            </div>
          </motion.div>

          {/* PvE Team */}
          <motion.div
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            className="p-6 border-2 border-neon-blue/50 rounded-lg hover:border-neon-blue transition-colors cursor-pointer"
            onClick={() => handleTeamSelect('pve')}
          >
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-xl font-semibold text-neon-blue">PvE Team</h3>
              <div className="w-8 h-8 rounded-full bg-neon-blue/20 flex items-center justify-center">
                <span className="text-neon-blue text-sm font-bold">E</span>
              </div>
            </div>
            <p className="text-gray-300 text-sm mb-3">
              Complete missions against AI enemies. Focus on cooperative gameplay and mission objectives.
            </p>
            <div className="flex justify-between text-xs text-gray-400">
              <span>Cooperative</span>
              <span>Player vs Environment</span>
            </div>
          </motion.div>
        </div>

        <div className="mt-6 text-center">
          <button
            onClick={onClose}
            className="px-4 py-2 text-gray-400 hover:text-white transition-colors"
          >
            Cancel
          </button>
        </div>
      </motion.div>
    </motion.div>
  )
} 