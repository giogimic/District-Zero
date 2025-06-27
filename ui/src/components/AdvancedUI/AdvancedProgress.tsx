import React from 'react';
import { motion } from 'framer-motion';

interface AdvancedProgressProps {
  value: number;
  max?: number;
  variant?: 'default' | 'primary' | 'success' | 'warning' | 'error';
  size?: 'sm' | 'md' | 'lg';
  showLabel?: boolean;
  showPercentage?: boolean;
  animated?: boolean;
  striped?: boolean;
  className?: string;
  label?: string;
}

export const AdvancedProgress: React.FC<AdvancedProgressProps> = ({
  value,
  max = 100,
  variant = 'default',
  size = 'md',
  showLabel = false,
  showPercentage = false,
  animated = true,
  striped = false,
  className = '',
  label,
}) => {
  const percentage = Math.min(Math.max((value / max) * 100, 0), 100);

  const sizeClasses = {
    sm: 'h-2',
    md: 'h-3',
    lg: 'h-4',
  };

  const variantClasses = {
    default: 'bg-base-300',
    primary: 'bg-primary',
    success: 'bg-success',
    warning: 'bg-warning',
    error: 'bg-error',
  };

  const progressClasses = {
    default: 'bg-base-content',
    primary: 'bg-primary-content',
    success: 'bg-success-content',
    warning: 'bg-warning-content',
    error: 'bg-error-content',
  };

  const baseClasses = 'w-full rounded-full overflow-hidden';
  const progressClass = `${progressClasses[variant]} ${striped ? 'bg-stripes' : ''}`;

  return (
    <div className={`${baseClasses} ${sizeClasses[size]} ${className}`}>
      {/* Background */}
      <div className={`w-full h-full ${variantClasses[variant]} opacity-20`} />
      
      {/* Progress bar */}
      <motion.div
        className={`h-full ${progressClass} relative`}
        initial={{ width: 0 }}
        animate={{ width: `${percentage}%` }}
        transition={animated ? { duration: 0.8, ease: 'easeOut' } : { duration: 0 }}
        style={{ position: 'absolute', top: 0, left: 0 }}
      >
        {/* Striped animation */}
        {striped && animated && (
          <motion.div
            className="absolute inset-0 bg-white/20"
            animate={{
              x: ['-100%', '100%'],
            }}
            transition={{
              duration: 1.5,
              repeat: Infinity,
              ease: 'linear',
            }}
            style={{
              background: 'linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent)',
            }}
          />
        )}
      </motion.div>

      {/* Label and percentage */}
      {(showLabel || showPercentage) && (
        <div className="flex justify-between items-center mt-2 text-sm">
          {showLabel && (
            <span className="text-base-content/70">
              {label || 'Progress'}
            </span>
          )}
          {showPercentage && (
            <span className="text-base-content/70 font-medium">
              {Math.round(percentage)}%
            </span>
          )}
        </div>
      )}
    </div>
  );
}; 