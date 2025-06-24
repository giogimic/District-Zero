import React, { useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useDistrictZeroStore, useCurrentTab, useLoading, useError } from './store'
import { closeNUI } from './utils/nui'
import { 
  DashboardTab, 
  DistrictsTab, 
  MissionsTab, 
  TeamsTab, 
  SettingsTab 
} from './components/tabs'
import { NotificationContainer } from './components/NotificationContainer'
import { TabNavigation } from './components/TabNavigation'
import { LoadingOverlay } from './components/LoadingOverlay'
import { ErrorBoundary } from './components/ErrorBoundary'

const App: React.FC = () => {
  const isOpen = useDistrictZeroStore((state) => state.isOpen)
  const currentTab = useCurrentTab()
  const loading = useLoading()
  const error = useError()

  // Handle escape key to close UI
  useEffect(() => {
    const handleKeyPress = (event: KeyboardEvent) => {
      if (event.key === 'Escape' && isOpen) {
        closeNUI()
      }
    }

    window.addEventListener('keydown', handleKeyPress)
    return () => window.removeEventListener('keydown', handleKeyPress)
  }, [isOpen])

  // Don't render if UI is not open
  if (!isOpen) {
    return null
  }

  return (
    <ErrorBoundary>
      <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          exit={{ opacity: 0, scale: 0.9 }}
          transition={{ duration: 0.3, ease: 'easeOut' }}
          className="relative w-full max-w-6xl h-full max-h-[90vh] glass p-6"
        >
          {/* Header */}
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center space-x-4">
              <h1 className="text-3xl font-bold neon-green neon-glow">
                District Zero
              </h1>
              <div className="text-sm text-gray-300">
                Mission Control System
              </div>
            </div>
            
            <button
              onClick={closeNUI}
              className="p-2 text-gray-400 hover:text-white transition-colors"
              aria-label="Close"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          {/* Tab Navigation */}
          <TabNavigation />

          {/* Main Content */}
          <div className="flex-1 overflow-hidden">
            <AnimatePresence mode="wait">
              <motion.div
                key={currentTab}
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                transition={{ duration: 0.3, ease: 'easeInOut' }}
                className="h-full"
              >
                {currentTab === 'dashboard' && <DashboardTab />}
                {currentTab === 'districts' && <DistrictsTab />}
                {currentTab === 'missions' && <MissionsTab />}
                {currentTab === 'teams' && <TeamsTab />}
                {currentTab === 'settings' && <SettingsTab />}
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Loading Overlay */}
          {loading && <LoadingOverlay />}

          {/* Error Display */}
          {error && (
            <div className="absolute top-4 right-4 bg-red-500/90 text-white px-4 py-2 rounded-lg">
              {error}
            </div>
          )}
        </motion.div>

        {/* Notifications */}
        <NotificationContainer />
      </div>
    </ErrorBoundary>
  )
}

export default App 