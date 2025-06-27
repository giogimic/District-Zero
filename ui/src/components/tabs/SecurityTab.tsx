import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { AnimatedCard, AdvancedProgress, AdvancedModal } from '../AdvancedUI';

interface SecurityMetrics {
  antiCheat: Record<string, any>;
  inputValidation: Record<string, any>;
  rateLimiting: Record<string, any>;
  threatDetection: Record<string, any>;
  accessControl: Record<string, any>;
  vulnerabilityScanning: Record<string, any>;
  overall: {
    totalEvents: number;
    totalThreats: number;
    totalViolations: number;
  };
}

interface SecurityLog {
  type: string;
  data: any;
  timestamp: number;
  serverId: string;
}

export const SecurityTab: React.FC = () => {
  const [metrics, setMetrics] = useState<SecurityMetrics | null>(null);
  const [logs, setLogs] = useState<SecurityLog[]>([]);
  const [selectedLog, setSelectedLog] = useState<SecurityLog | null>(null);
  const [logModalOpen, setLogModalOpen] = useState(false);
  const [activeTab, setActiveTab] = useState<'overview' | 'threats' | 'logs' | 'settings'>('overview');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchSecurityData = async () => {
      try {
        // Fetch security metrics
        const metricsResponse = await fetch('https://district-zero/api/security/metrics');
        const metricsData = await metricsResponse.json();
        setMetrics(metricsData);

        // Fetch security logs
        const logsResponse = await fetch('https://district-zero/api/security/logs');
        const logsData = await logsResponse.json();
        setLogs(logsData);
      } catch (error) {
        console.error('Failed to fetch security data:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchSecurityData();
    const interval = setInterval(fetchSecurityData, 30000); // Update every 30 seconds

    return () => clearInterval(interval);
  }, []);

  const formatTimestamp = (timestamp: number) => {
    return new Date(timestamp).toLocaleString();
  };

  const getThreatLevel = (threats: number) => {
    if (threats === 0) return { level: 'Low', color: 'success' };
    if (threats < 10) return { level: 'Medium', color: 'warning' };
    return { level: 'High', color: 'error' };
  };

  const getViolationLevel = (violations: number) => {
    if (violations === 0) return { level: 'None', color: 'success' };
    if (violations < 5) return { level: 'Low', color: 'info' };
    if (violations < 20) return { level: 'Medium', color: 'warning' };
    return { level: 'High', color: 'error' };
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="loading loading-spinner loading-lg"></div>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="text-center">
        <h1 className="text-3xl font-bold text-primary mb-2">Security Dashboard</h1>
        <p className="text-base-content/70">Monitor system security, threats, and violations</p>
      </div>

      {/* Tab Navigation */}
      <div className="tabs tabs-boxed justify-center">
        <button
          className={`tab ${activeTab === 'overview' ? 'tab-active' : ''}`}
          onClick={() => setActiveTab('overview')}
        >
          Overview
        </button>
        <button
          className={`tab ${activeTab === 'threats' ? 'tab-active' : ''}`}
          onClick={() => setActiveTab('threats')}
        >
          Threats
        </button>
        <button
          className={`tab ${activeTab === 'logs' ? 'tab-active' : ''}`}
          onClick={() => setActiveTab('logs')}
        >
          Security Logs
        </button>
        <button
          className={`tab ${activeTab === 'settings' ? 'tab-active' : ''}`}
          onClick={() => setActiveTab('settings')}
        >
          Settings
        </button>
      </div>

      {/* Overview Tab */}
      {activeTab === 'overview' && metrics && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="space-y-6"
        >
          {/* Security Status Cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <AnimatedCard variant="primary" hoverEffect={true}>
              <div className="text-center">
                <h3 className="text-lg font-semibold mb-2">Total Events</h3>
                <p className="text-3xl font-bold text-primary">{metrics.overall.totalEvents}</p>
                <p className="text-sm text-base-content/70">Security events logged</p>
              </div>
            </AnimatedCard>

            <AnimatedCard variant="error" hoverEffect={true}>
              <div className="text-center">
                <h3 className="text-lg font-semibold mb-2">Total Threats</h3>
                <p className="text-3xl font-bold text-error">{metrics.overall.totalThreats}</p>
                <p className="text-sm text-base-content/70">
                  Level: {getThreatLevel(metrics.overall.totalThreats).level}
                </p>
              </div>
            </AnimatedCard>

            <AnimatedCard variant="warning" hoverEffect={true}>
              <div className="text-center">
                <h3 className="text-lg font-semibold mb-2">Total Violations</h3>
                <p className="text-3xl font-bold text-warning">{metrics.overall.totalViolations}</p>
                <p className="text-sm text-base-content/70">
                  Level: {getViolationLevel(metrics.overall.totalViolations).level}
                </p>
              </div>
            </AnimatedCard>

            <AnimatedCard variant="success" hoverEffect={true}>
              <div className="text-center">
                <h3 className="text-lg font-semibold mb-2">System Status</h3>
                <p className="text-3xl font-bold text-success">Secure</p>
                <p className="text-sm text-base-content/70">All systems operational</p>
              </div>
            </AnimatedCard>
          </div>

          {/* Security Metrics */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* Anti-Cheat Metrics */}
            <AnimatedCard variant="default">
              <h3 className="text-xl font-semibold mb-4">Anti-Cheat Systems</h3>
              <div className="space-y-4">
                {Object.entries(metrics.antiCheat).map(([name, data]) => (
                  <div key={name} className="space-y-2">
                    <div className="flex justify-between items-center">
                      <span className="font-medium">{name}</span>
                      <span className="text-sm text-base-content/70">
                        {data.detections} detections
                      </span>
                    </div>
                    <AdvancedProgress
                      value={data.detections}
                      max={100}
                      variant="error"
                      showPercentage={false}
                    />
                  </div>
                ))}
              </div>
            </AnimatedCard>

            {/* Input Validation Metrics */}
            <AnimatedCard variant="default">
              <h3 className="text-xl font-semibold mb-4">Input Validation</h3>
              <div className="space-y-4">
                {Object.entries(metrics.inputValidation).map(([name, data]) => (
                  <div key={name} className="space-y-2">
                    <div className="flex justify-between items-center">
                      <span className="font-medium">{name}</span>
                      <span className="text-sm text-base-content/70">
                        {data.failureRate.toFixed(1)}% failure rate
                      </span>
                    </div>
                    <AdvancedProgress
                      value={data.failures}
                      max={data.validations || 1}
                      variant={data.failureRate > 5 ? 'error' : 'success'}
                      showPercentage={false}
                    />
                  </div>
                ))}
              </div>
            </AnimatedCard>
          </div>
        </motion.div>
      )}

      {/* Threats Tab */}
      {activeTab === 'threats' && metrics && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="space-y-6"
        >
          {/* Threat Detection */}
          <AnimatedCard variant="error">
            <h3 className="text-xl font-semibold mb-4">Threat Detection</h3>
            <div className="space-y-4">
              {Object.entries(metrics.threatDetection).map(([name, data]) => (
                <div key={name} className="p-4 bg-base-200 rounded-lg">
                  <div className="flex justify-between items-center mb-2">
                    <span className="font-medium">{name}</span>
                    <span className="text-error font-bold">{data.threats} threats</span>
                  </div>
                  {data.lastThreat > 0 && (
                    <p className="text-sm text-base-content/70">
                      Last threat: {formatTimestamp(data.lastThreat)}
                    </p>
                  )}
                </div>
              ))}
            </div>
          </AnimatedCard>

          {/* Rate Limiting */}
          <AnimatedCard variant="warning">
            <h3 className="text-xl font-semibold mb-4">Rate Limiting</h3>
            <div className="space-y-4">
              {Object.entries(metrics.rateLimiting).map(([name, data]) => (
                <div key={name} className="p-4 bg-base-200 rounded-lg">
                  <div className="flex justify-between items-center mb-2">
                    <span className="font-medium">{name}</span>
                    <span className="text-warning font-bold">{data.blocks} blocks</span>
                  </div>
                </div>
              ))}
            </div>
          </AnimatedCard>

          {/* Vulnerability Scanning */}
          <AnimatedCard variant="info">
            <h3 className="text-xl font-semibold mb-4">Vulnerability Scanning</h3>
            <div className="space-y-4">
              {Object.entries(metrics.vulnerabilityScanning).map(([name, data]) => (
                <div key={name} className="p-4 bg-base-200 rounded-lg">
                  <div className="flex justify-between items-center mb-2">
                    <span className="font-medium">{name}</span>
                    <span className="text-info font-bold">{data.vulnerabilities} vulnerabilities</span>
                  </div>
                  <p className="text-sm text-base-content/70">
                    {data.scans} scans performed
                  </p>
                </div>
              ))}
            </div>
          </AnimatedCard>
        </motion.div>
      )}

      {/* Logs Tab */}
      {activeTab === 'logs' && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="space-y-6"
        >
          <AnimatedCard variant="default">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-xl font-semibold">Security Logs</h3>
              <button
                className="btn btn-sm btn-outline"
                onClick={() => setLogs([])}
              >
                Clear Logs
              </button>
            </div>
            
            <div className="space-y-2 max-h-96 overflow-y-auto">
              {logs.length === 0 ? (
                <p className="text-center text-base-content/70 py-8">No security logs available</p>
              ) : (
                logs.map((log, index) => (
                  <div
                    key={index}
                    className="p-3 bg-base-200 rounded-lg cursor-pointer hover:bg-base-300 transition-colors"
                    onClick={() => {
                      setSelectedLog(log);
                      setLogModalOpen(true);
                    }}
                  >
                    <div className="flex justify-between items-center">
                      <div>
                        <span className="font-medium">{log.type}</span>
                        <p className="text-sm text-base-content/70">
                          {formatTimestamp(log.timestamp)}
                        </p>
                      </div>
                      <span className="text-xs text-base-content/50">
                        {log.serverId}
                      </span>
                    </div>
                  </div>
                ))
              )}
            </div>
          </AnimatedCard>
        </motion.div>
      )}

      {/* Settings Tab */}
      {activeTab === 'settings' && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="space-y-6"
        >
          <AnimatedCard variant="default">
            <h3 className="text-xl font-semibold mb-4">Security Settings</h3>
            <div className="space-y-4">
              <div className="form-control">
                <label className="label cursor-pointer">
                  <span className="label-text">Enable Anti-Cheat</span>
                  <input type="checkbox" className="toggle toggle-primary" defaultChecked />
                </label>
              </div>
              
              <div className="form-control">
                <label className="label cursor-pointer">
                  <span className="label-text">Enable Rate Limiting</span>
                  <input type="checkbox" className="toggle toggle-primary" defaultChecked />
                </label>
              </div>
              
              <div className="form-control">
                <label className="label cursor-pointer">
                  <span className="label-text">Enable Threat Detection</span>
                  <input type="checkbox" className="toggle toggle-primary" defaultChecked />
                </label>
              </div>
              
              <div className="form-control">
                <label className="label cursor-pointer">
                  <span className="label-text">Enable Vulnerability Scanning</span>
                  <input type="checkbox" className="toggle toggle-primary" defaultChecked />
                </label>
              </div>
              
              <div className="form-control">
                <label className="label cursor-pointer">
                  <span className="label-text">Enable Security Logging</span>
                  <input type="checkbox" className="toggle toggle-primary" defaultChecked />
                </label>
              </div>
            </div>
          </AnimatedCard>

          <AnimatedCard variant="default">
            <h3 className="text-xl font-semibold mb-4">Alert Settings</h3>
            <div className="space-y-4">
              <div className="form-control">
                <label className="label cursor-pointer">
                  <span className="label-text">High Threat Alerts</span>
                  <input type="checkbox" className="toggle toggle-error" defaultChecked />
                </label>
              </div>
              
              <div className="form-control">
                <label className="label cursor-pointer">
                  <span className="label-text">Rate Limit Violations</span>
                  <input type="checkbox" className="toggle toggle-warning" defaultChecked />
                </label>
              </div>
              
              <div className="form-control">
                <label className="label cursor-pointer">
                  <span className="label-text">Vulnerability Alerts</span>
                  <input type="checkbox" className="toggle toggle-info" defaultChecked />
                </label>
              </div>
            </div>
          </AnimatedCard>
        </motion.div>
      )}

      {/* Log Detail Modal */}
      <AdvancedModal
        isOpen={logModalOpen}
        onClose={() => setLogModalOpen(false)}
        title="Security Log Detail"
        size="lg"
      >
        {selectedLog && (
          <div className="space-y-4">
            <div>
              <h4 className="font-semibold">Event Type</h4>
              <p className="text-base-content/70">{selectedLog.type}</p>
            </div>
            
            <div>
              <h4 className="font-semibold">Timestamp</h4>
              <p className="text-base-content/70">{formatTimestamp(selectedLog.timestamp)}</p>
            </div>
            
            <div>
              <h4 className="font-semibold">Server ID</h4>
              <p className="text-base-content/70">{selectedLog.serverId}</p>
            </div>
            
            <div>
              <h4 className="font-semibold">Data</h4>
              <pre className="bg-base-200 p-3 rounded-lg text-sm overflow-x-auto">
                {JSON.stringify(selectedLog.data, null, 2)}
              </pre>
            </div>
          </div>
        )}
      </AdvancedModal>
    </div>
  );
}; 