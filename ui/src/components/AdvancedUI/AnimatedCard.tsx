import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

interface AnimatedCardProps {
  children: React.ReactNode;
  className?: string;
  onClick?: () => void;
  disabled?: boolean;
  loading?: boolean;
  variant?: 'default' | 'primary' | 'success' | 'warning' | 'error';
  size?: 'sm' | 'md' | 'lg';
  hoverEffect?: boolean;
  pulseEffect?: boolean;
  glowEffect?: boolean;
}

export const AnimatedCard: React.FC<AnimatedCardProps> = ({
  children,
  className = '',
  onClick,
  disabled = false,
  loading = false,
  variant = 'default',
  size = 'md',
  hoverEffect = true,
  pulseEffect = false,
  glowEffect = false,
}) => {
  const [isHovered, setIsHovered] = useState(false);

  const baseClasses = 'relative overflow-hidden rounded-lg transition-all duration-300';
  
  const variantClasses = {
    default: 'bg-base-200 border border-base-300',
    primary: 'bg-primary/20 border border-primary/30 text-primary',
    success: 'bg-success/20 border border-success/30 text-success',
    warning: 'bg-warning/20 border border-warning/30 text-warning',
    error: 'bg-error/20 border border-error/30 text-error',
  };

  const sizeClasses = {
    sm: 'p-3',
    md: 'p-4',
    lg: 'p-6',
  };

  const hoverClasses = hoverEffect ? 'hover:scale-105 hover:shadow-lg' : '';
  const pulseClasses = pulseEffect ? 'animate-pulse' : '';
  const glowClasses = glowEffect ? 'neon-glow' : '';
  const disabledClasses = disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer';

  const cardClasses = [
    baseClasses,
    variantClasses[variant],
    sizeClasses[size],
    hoverClasses,
    pulseClasses,
    glowClasses,
    disabledClasses,
    className,
  ].filter(Boolean).join(' ');

  const handleClick = () => {
    if (!disabled && !loading && onClick) {
      onClick();
    }
  };

  return (
    <motion.div
      className={cardClasses}
      onClick={handleClick}
      onHoverStart={() => setIsHovered(true)}
      onHoverEnd={() => setIsHovered(false)}
      whileHover={!disabled && !loading ? { scale: 1.02 } : {}}
      whileTap={!disabled && !loading ? { scale: 0.98 } : {}}
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3, ease: 'easeOut' }}
    >
      {/* Loading Overlay */}
      <AnimatePresence>
        {loading && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="absolute inset-0 bg-base-300/50 flex items-center justify-center z-10"
          >
            <div className="loading loading-spinner loading-md"></div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Hover Effect Overlay */}
      <AnimatePresence>
        {isHovered && hoverEffect && !disabled && !loading && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="absolute inset-0 bg-gradient-to-r from-transparent via-white/5 to-transparent"
            style={{
              background: `linear-gradient(90deg, transparent, rgba(255,255,255,0.1), transparent)`,
            }}
          />
        )}
      </AnimatePresence>

      {/* Content */}
      <div className="relative z-0">
        {children}
      </div>

      {/* Glow Effect */}
      {glowEffect && (
        <div className="absolute inset-0 rounded-lg bg-gradient-to-r from-primary/20 via-transparent to-primary/20 opacity-0 hover:opacity-100 transition-opacity duration-300" />
      )}
    </motion.div>
  );
}; 