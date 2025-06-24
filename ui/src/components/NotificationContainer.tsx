import React, { useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useDistrictZeroStore } from '../store'

export const NotificationContainer: React.FC = () => {
  const notifications = useDistrictZeroStore((state) => state.notifications)
  const removeNotification = useDistrictZeroStore((state) => state.removeNotification)

  useEffect(() => {
    notifications.forEach((notification) => {
      if (notification.duration) {
        const timer = setTimeout(() => {
          removeNotification(notification.id)
        }, notification.duration)
        return () => clearTimeout(timer)
      }
    })
  }, [notifications, removeNotification])

  return (
    <div className="fixed top-4 right-4 z-50 space-y-2">
      <AnimatePresence>
        {notifications.map((notification) => (
          <motion.div
            key={notification.id}
            initial={{ opacity: 0, x: 300 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: 300 }}
            className={`notification glass p-4 min-w-80 ${notification.type}`}
          >
            <div className="flex items-start justify-between">
              <div className="flex-1">
                {notification.title && (
                  <h4 className="font-semibold text-white mb-1">{notification.title}</h4>
                )}
                <p className="text-gray-200">{notification.message}</p>
              </div>
              <button
                onClick={() => removeNotification(notification.id)}
                className="ml-4 text-gray-400 hover:text-white transition-colors"
                aria-label="Dismiss notification"
              >
                ×
              </button>
            </div>
          </motion.div>
        ))}
      </AnimatePresence>
    </div>
  )
} 