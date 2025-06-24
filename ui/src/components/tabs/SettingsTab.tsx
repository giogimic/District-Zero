import React from 'react'

export const SettingsTab: React.FC = () => {
  return (
    <div className="h-full overflow-y-auto space-y-6">
      <div className="glass p-6">
        <h3 className="text-xl font-semibold text-white mb-4">UI Settings</h3>
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <span className="text-gray-300">Notifications</span>
            <input type="checkbox" className="toggle toggle-success" defaultChecked />
          </div>
          <div className="flex items-center justify-between">
            <span className="text-gray-300">Sound Effects</span>
            <input type="checkbox" className="toggle toggle-success" defaultChecked />
          </div>
          <div className="flex items-center justify-between">
            <span className="text-gray-300">Animations</span>
            <input type="checkbox" className="toggle toggle-success" defaultChecked />
          </div>
        </div>
      </div>

      <div className="glass p-6">
        <h3 className="text-xl font-semibold text-white mb-4">Game Settings</h3>
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <span className="text-gray-300">Auto-accept Missions</span>
            <input type="checkbox" className="toggle toggle-warning" />
          </div>
          <div className="flex items-center justify-between">
            <span className="text-gray-300">Show Mission Blips</span>
            <input type="checkbox" className="toggle toggle-success" defaultChecked />
          </div>
          <div className="flex items-center justify-between">
            <span className="text-gray-300">Show District Boundaries</span>
            <input type="checkbox" className="toggle toggle-success" defaultChecked />
          </div>
        </div>
      </div>

      <div className="glass p-6">
        <h3 className="text-xl font-semibold text-white mb-4">About</h3>
        <div className="space-y-2 text-gray-300">
          <p>District Zero v1.0.0</p>
          <p>A dynamic district control and mission system for FiveM</p>
          <p>Inspired by APB Reloaded</p>
        </div>
      </div>
    </div>
  )
} 