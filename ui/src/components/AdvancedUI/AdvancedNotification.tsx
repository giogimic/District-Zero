import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

interface AdvancedNotificationProps {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info' | 'progress';
  title: string;
  message?: string;
  duration?: number;
  progress?: number;
  onClose: (id: string) => void;
  actions?: Array<{
    label: string;
    onClick: () => void;
    variant?: 'primary' | 'secondary' | 'outline';
  }>;
  icon?: React.ReactNode;
  className?: string;
}

export const AdvancedNotification: React.FC<AdvancedNotificationProps> = ({
  id,
  type,
  title,
  message,
  duration = 5000,
  progress,
  onClose,
  actions,
  icon,
  className = '',
}) => {
  const [isVisible, setIsVisible] = useState(true);
  const [timeLeft, setTimeLeft] = useState(duration);

  // Auto-dismiss timer
  useEffect(() => {
    if (duration === 0) return;

    const timer = setInterval(() => {
      setTimeLeft((prev) => {
        if (prev <= 100) {
          setIsVisible(false);
          return 0;
        }
        return prev - 100;
      });
    }, 100);

    return () => clearInterval(timer);
  }, [duration]);

  // Handle close animation
  const handleClose = () => {
    setIsVisible(false);
    setTimeout(() => onClose(id), 300);
  };

  // Type-specific styles
  const typeStyles = {
    success: {
      bg: 'bg-success/20',
      border: 'border-success/30',
      text: 'text-success',
      icon: 'text-success',
      progress: 'bg-success',
    },
    error: {
      bg: 'bg-error/20',
      border: 'border-error/30',
      text: 'text-error',
      icon: 'text-error',
      progress: 'bg-error',
    },
    warning: {
      bg: 'bg-warning/20',
      border: 'border-warning/30',
      text: 'text-warning',
      icon: 'text-warning',
      progress: 'bg-warning',
    },
    info: {
      bg: 'bg-info/20',
      border: 'border-info/30',
      text: 'text-info',
      icon: 'text-info',
      progress: 'bg-info',
    },
    progress: {
      bg: 'bg-primary/20',
      border: 'border-primary/30',
      text: 'text-primary',
      icon: 'text-primary',
      progress: 'bg-primary',
    },
  };

  // Default icons
  const defaultIcons = {
    success: (
      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
      </svg>
    ),
    error: (
      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
      </svg>
    ),
    warning: (
      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
      </svg>
    ),
    info: (
      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
    ),
    progress: (
      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
    ),
  };

  const styles = typeStyles[type];
  const notificationIcon = icon || defaultIcons[type];

  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          initial={{ opacity: 0, x: 300, scale: 0.8 }}
          animate={{ opacity: 1, x: 0, scale: 1 }}
          exit={{ opacity: 0, x: 300, scale: 0.8 }}
          transition={{ type: 'spring', damping: 25, stiffness: 300 }}
          className={`relative w-full max-w-sm ${styles.bg} ${styles.border} border rounded-lg shadow-lg overflow-hidden ${className}`}
        >
          {/* Progress bar */}
          {duration > 0 && (
            <div className="absolute top-0 left-0 right-0 h-1 bg-base-300">
              <motion.div
                className={`h-full ${styles.progress}`}
                initial={{ width: '100%' }}
                animate={{ width: '0%' }}
                transition={{ duration: duration / 1000, ease: 'linear' }}
              />
            </div>
          )}

          {/* Content */}
          <div className="p-4">
            <div className="flex items-start space-x-3">
              {/* Icon */}
              <div className={`flex-shrink-0 ${styles.icon}`}>
                {notificationIcon}
              </div>

              {/* Text content */}
              <div className="flex-1 min-w-0">
                <h4 className={`text-sm font-semibold ${styles.text}`}>
                  {title}
                </h4>
                {message && (
                  <p className="mt-1 text-sm text-base-content/70">
                    {message}
                  </p>
                )}

                {/* Progress indicator */}
                {type === 'progress' && progress !== undefined && (
                  <div className="mt-2">
                    <div className="flex justify-between text-xs text-base-content/60 mb-1">
                      <span>Progress</span>
                      <span>{Math.round(progress)}%</span>
                    </div>
                    <div className="w-full bg-base-300 rounded-full h-2">
                      <motion.div
                        className={`h-2 rounded-full ${styles.progress}`}
                        initial={{ width: 0 }}
                        animate={{ width: `${progress}%` }}
                        transition={{ duration: 0.5, ease: 'easeOut' }}
                      />
                    </div>
                  </div>
                )}

                {/* Actions */}
                {actions && actions.length > 0 && (
                  <div className="flex space-x-2 mt-3">
                    {actions.map((action, index) => (
                      <button
                        key={index}
                        onClick={action.onClick}
                        className={`px-3 py-1 text-xs rounded-md transition-colors ${
                          action.variant === 'primary'
                            ? 'bg-primary text-primary-content hover:bg-primary/80'
                            : action.variant === 'secondary'
                            ? 'bg-secondary text-secondary-content hover:bg-secondary/80'
                            : 'bg-base-200 text-base-content hover:bg-base-300'
                        }`}
                      >
                        {action.label}
                      </button>
                    ))}
                  </div>
                )}
              </div>

              {/* Close button */}
              <button
                onClick={handleClose}
                className="flex-shrink-0 p-1 text-base-content/40 hover:text-base-content hover:bg-base-200 rounded transition-colors"
                aria-label="Close notification"
              >
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}; 