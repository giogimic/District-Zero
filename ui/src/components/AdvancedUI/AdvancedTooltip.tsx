import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

interface AdvancedTooltipProps {
  content: React.ReactNode;
  children: React.ReactNode;
  position?: 'top' | 'bottom' | 'left' | 'right' | 'top-left' | 'top-right' | 'bottom-left' | 'bottom-right';
  delay?: number;
  maxWidth?: number;
  variant?: 'default' | 'primary' | 'success' | 'warning' | 'error';
  showArrow?: boolean;
  className?: string;
  disabled?: boolean;
}

export const AdvancedTooltip: React.FC<AdvancedTooltipProps> = ({
  content,
  children,
  position = 'top',
  delay = 200,
  maxWidth = 300,
  variant = 'default',
  showArrow = true,
  className = '',
  disabled = false,
}) => {
  const [isVisible, setIsVisible] = useState(false);
  const [tooltipPosition, setTooltipPosition] = useState({ x: 0, y: 0 });
  const triggerRef = useRef<HTMLDivElement>(null);
  const tooltipRef = useRef<HTMLDivElement>(null);
  const timeoutRef = useRef<number>();

  // Variant styles
  const variantStyles = {
    default: {
      bg: 'bg-base-200',
      border: 'border-base-300',
      text: 'text-base-content',
      arrow: 'border-base-200',
    },
    primary: {
      bg: 'bg-primary',
      border: 'border-primary',
      text: 'text-primary-content',
      arrow: 'border-primary',
    },
    success: {
      bg: 'bg-success',
      border: 'border-success',
      text: 'text-success-content',
      arrow: 'border-success',
    },
    warning: {
      bg: 'bg-warning',
      border: 'border-warning',
      text: 'text-warning-content',
      arrow: 'border-warning',
    },
    error: {
      bg: 'bg-error',
      border: 'border-error',
      text: 'text-error-content',
      arrow: 'border-error',
    },
  };

  const styles = variantStyles[variant];

  // Calculate tooltip position
  const calculatePosition = () => {
    if (!triggerRef.current || !tooltipRef.current) return;

    const triggerRect = triggerRef.current.getBoundingClientRect();
    const tooltipRect = tooltipRef.current.getBoundingClientRect();
    const scrollX = window.pageXOffset || document.documentElement.scrollLeft;
    const scrollY = window.pageYOffset || document.documentElement.scrollTop;

    let x = 0;
    let y = 0;

    switch (position) {
      case 'top':
        x = triggerRect.left + triggerRect.width / 2 - tooltipRect.width / 2 + scrollX;
        y = triggerRect.top - tooltipRect.height - 8 + scrollY;
        break;
      case 'bottom':
        x = triggerRect.left + triggerRect.width / 2 - tooltipRect.width / 2 + scrollX;
        y = triggerRect.bottom + 8 + scrollY;
        break;
      case 'left':
        x = triggerRect.left - tooltipRect.width - 8 + scrollX;
        y = triggerRect.top + triggerRect.height / 2 - tooltipRect.height / 2 + scrollY;
        break;
      case 'right':
        x = triggerRect.right + 8 + scrollX;
        y = triggerRect.top + triggerRect.height / 2 - tooltipRect.height / 2 + scrollY;
        break;
      case 'top-left':
        x = triggerRect.left + scrollX;
        y = triggerRect.top - tooltipRect.height - 8 + scrollY;
        break;
      case 'top-right':
        x = triggerRect.right - tooltipRect.width + scrollX;
        y = triggerRect.top - tooltipRect.height - 8 + scrollY;
        break;
      case 'bottom-left':
        x = triggerRect.left + scrollX;
        y = triggerRect.bottom + 8 + scrollY;
        break;
      case 'bottom-right':
        x = triggerRect.right - tooltipRect.width + scrollX;
        y = triggerRect.bottom + 8 + scrollY;
        break;
    }

    // Ensure tooltip stays within viewport
    const viewportWidth = window.innerWidth;
    const viewportHeight = window.innerHeight;

    if (x < 0) x = 8;
    if (x + tooltipRect.width > viewportWidth) x = viewportWidth - tooltipRect.width - 8;
    if (y < 0) y = 8;
    if (y + tooltipRect.height > viewportHeight) y = viewportHeight - tooltipRect.height - 8;

    setTooltipPosition({ x, y });
  };

  // Handle mouse events
  const handleMouseEnter = () => {
    if (disabled) return;
    
    timeoutRef.current = setTimeout(() => {
      setIsVisible(true);
      setTimeout(calculatePosition, 10);
    }, delay);
  };

  const handleMouseLeave = () => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }
    setIsVisible(false);
  };

  // Handle scroll and resize
  useEffect(() => {
    if (isVisible) {
      const handleScroll = () => calculatePosition();
      const handleResize = () => calculatePosition();

      window.addEventListener('scroll', handleScroll, true);
      window.addEventListener('resize', handleResize);

      return () => {
        window.removeEventListener('scroll', handleScroll, true);
        window.removeEventListener('resize', handleResize);
      };
    }
  }, [isVisible]);

  // Cleanup timeout on unmount
  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, []);

  // Arrow styles based on position
  const getArrowStyles = () => {
    const baseArrow = 'absolute w-0 h-0 border-4 border-transparent';
    
    switch (position) {
      case 'top':
        return `${baseArrow} ${styles.arrow} border-t-4 border-l-4 border-r-4 border-b-0 bottom-0 left-1/2 transform -translate-x-1/2 translate-y-full`;
      case 'bottom':
        return `${baseArrow} ${styles.arrow} border-b-4 border-l-4 border-r-4 border-t-0 top-0 left-1/2 transform -translate-x-1/2 -translate-y-full`;
      case 'left':
        return `${baseArrow} ${styles.arrow} border-l-4 border-t-4 border-b-4 border-r-0 right-0 top-1/2 transform -translate-y-1/2 translate-x-full`;
      case 'right':
        return `${baseArrow} ${styles.arrow} border-r-4 border-t-4 border-b-4 border-l-0 left-0 top-1/2 transform -translate-y-1/2 -translate-x-full`;
      case 'top-left':
        return `${baseArrow} ${styles.arrow} border-t-4 border-l-4 border-r-4 border-b-0 bottom-0 left-4 translate-y-full`;
      case 'top-right':
        return `${baseArrow} ${styles.arrow} border-t-4 border-l-4 border-r-4 border-b-0 bottom-0 right-4 translate-y-full`;
      case 'bottom-left':
        return `${baseArrow} ${styles.arrow} border-b-4 border-l-4 border-r-4 border-t-0 top-0 left-4 -translate-y-full`;
      case 'bottom-right':
        return `${baseArrow} ${styles.arrow} border-b-4 border-l-4 border-r-4 border-t-0 top-0 right-4 -translate-y-full`;
      default:
        return '';
    }
  };

  return (
    <div
      ref={triggerRef}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
      className="inline-block"
    >
      {children}
      
      <AnimatePresence>
        {isVisible && (
          <motion.div
            ref={tooltipRef}
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.8 }}
            transition={{ duration: 0.2, ease: 'easeOut' }}
            style={{
              position: 'fixed',
              left: tooltipPosition.x,
              top: tooltipPosition.y,
              zIndex: 9999,
              maxWidth,
            }}
            className={`${styles.bg} ${styles.border} border rounded-lg shadow-lg p-3 ${styles.text} text-sm ${className}`}
          >
            {showArrow && <div className={getArrowStyles()} />}
            <div className="relative z-10">
              {content}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}; 