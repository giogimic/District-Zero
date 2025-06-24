import React from 'react'
import { motion } from 'framer-motion'

export const LoadingOverlay: React.FC = () => {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="absolute inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50"
    >
      <div className="glass p-8 rounded-lg flex flex-col items-center space-y-4">
        <div className="spinner" />
        <p className="text-white font-medium">Loading...</p>
      </div>
    </motion.div>
  )
} 