import React, { useState } from 'react';
import { motion } from 'framer-motion';
import {
  AnimatedCard,
  AdvancedModal,
  AdvancedNotification,
  AdvancedTooltip,
  AdvancedProgress,
} from '../AdvancedUI';

export const AdvancedUIDemoTab: React.FC = () => {
  const [modalOpen, setModalOpen] = useState(false);
  const [notifications, setNotifications] = useState<Array<{
    id: string;
    type: 'success' | 'error' | 'warning' | 'info' | 'progress';
    title: string;
    message: string;
    progress?: number;
  }>>([]);

  const addNotification = (type: 'success' | 'error' | 'warning' | 'info' | 'progress', title: string, message: string, progress?: number) => {
    const id = Date.now().toString();
    setNotifications(prev => [...prev, { id, type, title, message, progress }]);
  };

  const removeNotification = (id: string) => {
    setNotifications(prev => prev.filter(n => n.id !== id));
  };

  return (
    <div className="p-6 space-y-8">
      {/* Header */}
      <div className="text-center">
        <h1 className="text-3xl font-bold text-primary mb-2">Advanced UI Features</h1>
        <p className="text-base-content/70">Showcase of enhanced UI components and animations</p>
      </div>

      {/* Animated Cards Section */}
      <section className="space-y-4">
        <h2 className="text-2xl font-semibold text-base-content">Animated Cards</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <AnimatedCard
            variant="primary"
            hoverEffect={true}
            glowEffect={true}
            onClick={() => console.log('Primary card clicked')}
          >
            <h3 className="font-bold text-lg mb-2">Primary Card</h3>
            <p className="text-sm text-base-content/70">
              This card has hover effects and glow animation.
            </p>
          </AnimatedCard>

          <AnimatedCard
            variant="success"
            pulseEffect={true}
            onClick={() => console.log('Success card clicked')}
          >
            <h3 className="font-bold text-lg mb-2">Success Card</h3>
            <p className="text-sm text-base-content/70">
              This card has a pulsing animation effect.
            </p>
          </AnimatedCard>

          <AnimatedCard
            variant="warning"
            loading={true}
            onClick={() => console.log('Warning card clicked')}
          >
            <h3 className="font-bold text-lg mb-2">Loading Card</h3>
            <p className="text-sm text-base-content/70">
              This card shows a loading state.
            </p>
          </AnimatedCard>
        </div>
      </section>

      {/* Progress Bars Section */}
      <section className="space-y-4">
        <h2 className="text-2xl font-semibold text-base-content">Progress Bars</h2>
        <div className="space-y-6">
          <div>
            <h3 className="text-lg font-medium mb-3">Default Progress</h3>
            <AdvancedProgress
              value={75}
              showLabel={true}
              showPercentage={true}
              label="Mission Progress"
            />
          </div>

          <div>
            <h3 className="text-lg font-medium mb-3">Animated Striped Progress</h3>
            <AdvancedProgress
              value={45}
              variant="primary"
              size="lg"
              striped={true}
              animated={true}
              showPercentage={true}
            />
          </div>

          <div>
            <h3 className="text-lg font-medium mb-3">Success Progress</h3>
            <AdvancedProgress
              value={90}
              variant="success"
              size="sm"
              showLabel={true}
              showPercentage={true}
              label="Health"
            />
          </div>
        </div>
      </section>

      {/* Tooltips Section */}
      <section className="space-y-4">
        <h2 className="text-2xl font-semibold text-base-content">Tooltips</h2>
        <div className="flex flex-wrap gap-4">
          <AdvancedTooltip
            content="This is a default tooltip with helpful information"
            position="top"
          >
            <button className="btn btn-primary">Hover for Tooltip (Top)</button>
          </AdvancedTooltip>

          <AdvancedTooltip
            content="This tooltip appears on the right side"
            position="right"
            variant="success"
          >
            <button className="btn btn-success">Tooltip Right</button>
          </AdvancedTooltip>

          <AdvancedTooltip
            content="This tooltip has a warning style"
            position="bottom"
            variant="warning"
          >
            <button className="btn btn-warning">Tooltip Bottom</button>
          </AdvancedTooltip>

          <AdvancedTooltip
            content="This tooltip appears on the left side"
            position="left"
            variant="error"
          >
            <button className="btn btn-error">Tooltip Left</button>
          </AdvancedTooltip>
        </div>
      </section>

      {/* Modal Section */}
      <section className="space-y-4">
        <h2 className="text-2xl font-semibold text-base-content">Modals</h2>
        <div className="flex flex-wrap gap-4">
          <button
            className="btn btn-primary"
            onClick={() => setModalOpen(true)}
          >
            Open Modal
          </button>
        </div>

        <AdvancedModal
          isOpen={modalOpen}
          onClose={() => setModalOpen(false)}
          title="Advanced Modal Demo"
          size="lg"
          variant="primary"
        >
          <div className="space-y-4">
            <p>This is an advanced modal with animations and backdrop blur.</p>
            <div className="flex justify-end space-x-2">
              <button
                className="btn btn-outline"
                onClick={() => setModalOpen(false)}
              >
                Cancel
              </button>
              <button
                className="btn btn-primary"
                onClick={() => setModalOpen(false)}
              >
                Confirm
              </button>
            </div>
          </div>
        </AdvancedModal>
      </section>

      {/* Notifications Section */}
      <section className="space-y-4">
        <h2 className="text-2xl font-semibold text-base-content">Notifications</h2>
        <div className="flex flex-wrap gap-4">
          <button
            className="btn btn-success"
            onClick={() => addNotification('success', 'Success!', 'Operation completed successfully')}
          >
            Success Notification
          </button>

          <button
            className="btn btn-error"
            onClick={() => addNotification('error', 'Error!', 'Something went wrong')}
          >
            Error Notification
          </button>

          <button
            className="btn btn-warning"
            onClick={() => addNotification('warning', 'Warning!', 'Please check your input')}
          >
            Warning Notification
          </button>

          <button
            className="btn btn-info"
            onClick={() => addNotification('info', 'Info', 'Here is some information')}
          >
            Info Notification
          </button>

          <button
            className="btn btn-primary"
            onClick={() => addNotification('progress', 'Uploading...', 'File upload in progress', 65)}
          >
            Progress Notification
          </button>
        </div>

        {/* Notification Display */}
        <div className="fixed top-4 right-4 space-y-2 z-50">
          {notifications.map((notification) => (
            <AdvancedNotification
              key={notification.id}
              id={notification.id}
              type={notification.type}
              title={notification.title}
              message={notification.message}
              progress={notification.progress}
              onClose={removeNotification}
              duration={5000}
            />
          ))}
        </div>
      </section>

      {/* Animation Showcase */}
      <section className="space-y-4">
        <h2 className="text-2xl font-semibold text-base-content">Animation Showcase</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <motion.div
            className="p-6 bg-base-200 rounded-lg"
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            <h3 className="text-lg font-medium mb-2">Hover & Tap Animations</h3>
            <p className="text-sm text-base-content/70">
              This card responds to hover and tap interactions with smooth animations.
            </p>
          </motion.div>

          <motion.div
            className="p-6 bg-primary/20 rounded-lg"
            animate={{
              y: [0, -10, 0],
            }}
            transition={{
              duration: 2,
              repeat: Infinity,
              ease: 'easeInOut',
            }}
          >
            <h3 className="text-lg font-medium mb-2">Floating Animation</h3>
            <p className="text-sm text-base-content/70">
              This card has a continuous floating animation.
            </p>
          </motion.div>
        </div>
      </section>

      {/* Interactive Demo */}
      <section className="space-y-4">
        <h2 className="text-2xl font-semibold text-base-content">Interactive Demo</h2>
        <div className="p-6 bg-base-200 rounded-lg">
          <h3 className="text-lg font-medium mb-4">Try the Components</h3>
          <div className="space-y-4">
            <p className="text-sm text-base-content/70">
              Click the buttons above to see the different UI components in action.
              Each component demonstrates various features like animations, variants, and interactions.
            </p>
            
            <div className="flex flex-wrap gap-2">
              <AdvancedTooltip content="This button has a tooltip!">
                <button className="btn btn-outline">Interactive Button</button>
              </AdvancedTooltip>
              
              <AnimatedCard variant="primary" hoverEffect={true}>
                <div className="text-center">
                  <h4 className="font-medium">Interactive Card</h4>
                  <p className="text-sm text-base-content/70">Hover to see effects</p>
                </div>
              </AnimatedCard>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}; 