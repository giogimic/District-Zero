import React, { useState, useEffect, useCallback } from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/nui';

interface AnalyticsMetric {
  metricId: string;
  name: string;
  description: string;
  category: string;
  type: string;
  unit: string;
  value: any;
  timestamp: number;
  dataPoints: number;
}

interface AnalyticsDashboard {
  id: string;
  name: string;
  description: string;
  layout: string;
  refreshInterval: number;
  metrics: AnalyticsMetric[];
}

interface AnalyticsData {
  dashboards: Record<string, { data: AnalyticsDashboard; timestamp: number }>;
  metrics: Record<string, { data: AnalyticsMetric; timestamp: number }>;
  lastUpdate: number;
}

export const AnalyticsTab: React.FC = () => {
  const [analyticsData, setAnalyticsData] = useState<AnalyticsData>({
    dashboards: {},
    metrics: {},
    lastUpdate: 0
  });
  const [selectedDashboard, setSelectedDashboard] = useState<string>('overview');
  const [selectedMetric, setSelectedMetric] = useState<string>('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string>('');

  // Available dashboards
  const availableDashboards = [
    { id: 'overview', name: 'Overview Dashboard', description: 'General system overview and key metrics' },
    { id: 'player_analytics', name: 'Player Analytics', description: 'Player behavior and performance analytics' },
    { id: 'team_analytics', name: 'Team Analytics', description: 'Team performance and competitive analytics' },
    { id: 'system_analytics', name: 'System Analytics', description: 'System performance and health monitoring' }
  ];

  // Available metrics
  const availableMetrics = [
    { id: 'player_session_time', name: 'Session Duration', category: 'Player Behavior' },
    { id: 'player_activity_patterns', name: 'Activity Patterns', category: 'Player Behavior' },
    { id: 'player_movement_analysis', name: 'Movement Analysis', category: 'Player Behavior' },
    { id: 'player_combat_behavior', name: 'Combat Behavior', category: 'Player Behavior' },
    { id: 'team_capture_efficiency', name: 'Capture Efficiency', category: 'Team Performance' },
    { id: 'team_mission_completion', name: 'Mission Completion', category: 'Team Performance' },
    { id: 'team_war_performance', name: 'War Performance', category: 'Team Performance' },
    { id: 'district_control_duration', name: 'Control Duration', category: 'District Control' },
    { id: 'district_capture_frequency', name: 'Capture Frequency', category: 'District Control' },
    { id: 'mission_completion_rate', name: 'Completion Rate', category: 'Mission Statistics' },
    { id: 'mission_difficulty_analysis', name: 'Difficulty Analysis', category: 'Mission Statistics' },
    { id: 'server_performance', name: 'Server Performance', category: 'System Metrics' },
    { id: 'economic_flow', name: 'Economic Flow', category: 'Economic Analytics' },
    { id: 'social_interactions', name: 'Social Interactions', category: 'Social Analytics' },
    { id: 'performance_metrics', name: 'Performance Metrics', category: 'Performance Analytics' }
  ];

  // Load analytics data
  const loadAnalyticsData = useCallback(async () => {
    try {
      setIsLoading(true);
      setError('');
      
      const response = await fetchNui<{ success: boolean; dashboards: Record<string, { data: AnalyticsDashboard; timestamp: number }>; metrics: Record<string, { data: AnalyticsMetric; timestamp: number }>; lastUpdate: number }>('getAnalyticsData');
      if (response.success) {
        setAnalyticsData({
          dashboards: response.dashboards,
          metrics: response.metrics,
          lastUpdate: response.lastUpdate
        });
      } else {
        setError('Failed to load analytics data');
      }
    } catch (err) {
      setError('Error loading analytics data');
      console.error('Analytics data load error:', err);
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Request dashboard
  const requestDashboard = useCallback(async (dashboardId: string) => {
    try {
      setError('');
      const response = await fetchNui('requestAnalyticsDashboard', { dashboardId });
      if (response.success) {
        console.log('Dashboard requested:', dashboardId);
      } else {
        setError(response.message || 'Failed to request dashboard');
      }
    } catch (err) {
      setError('Error requesting dashboard');
      console.error('Dashboard request error:', err);
    }
  }, []);

  // Request metric
  const requestMetric = useCallback(async (metricId: string) => {
    try {
      setError('');
      const response = await fetchNui('requestAnalyticsMetric', { metricId });
      if (response.success) {
        console.log('Metric requested:', metricId);
      } else {
        setError(response.message || 'Failed to request metric');
      }
    } catch (err) {
      setError('Error requesting metric');
      console.error('Metric request error:', err);
    }
  }, []);

  // Track analytics event
  const trackEvent = useCallback(async (category: string, eventType: string, data: any = {}) => {
    try {
      setError('');
      const response = await fetchNui('trackAnalyticsEvent', { category, eventType, data });
      if (response.success) {
        console.log('Event tracked:', category, eventType);
      } else {
        setError(response.message || 'Failed to track event');
      }
    } catch (err) {
      setError('Error tracking event');
      console.error('Event tracking error:', err);
    }
  }, []);

  // Handle dashboard updates
  useNuiEvent('analytics_dashboard_update', (data: any) => {
    const { dashboardId, dashboardData } = data;
    setAnalyticsData(prev => ({
      ...prev,
      dashboards: {
        ...prev.dashboards,
        [dashboardId]: {
          data: dashboardData,
          timestamp: Date.now()
        }
      }
    }));
  });

  // Handle metric updates
  useNuiEvent('analytics_metric_update', (data: any) => {
    const { metricId, metricData } = data;
    setAnalyticsData(prev => ({
      ...prev,
      metrics: {
        ...prev.metrics,
        [metricId]: {
          data: metricData,
          timestamp: Date.now()
        }
      }
    }));
  });

  // Load data on mount
  useEffect(() => {
    loadAnalyticsData();
  }, [loadAnalyticsData]);

  // Auto-refresh dashboard
  useEffect(() => {
    if (selectedDashboard) {
      requestDashboard(selectedDashboard);
    }
  }, [selectedDashboard, requestDashboard]);

  // Auto-refresh metric
  useEffect(() => {
    if (selectedMetric) {
      requestMetric(selectedMetric);
    }
  }, [selectedMetric, requestMetric]);

  // Format metric value
  const formatMetricValue = (metric: AnalyticsMetric) => {
    const value = metric.value;
    
    if (typeof value === 'number') {
      if (metric.unit === '%') {
        return `${value.toFixed(1)}%`;
      } else if (metric.unit === 'minutes') {
        return `${Math.floor(value)}m ${Math.floor((value % 1) * 60)}s`;
      } else if (metric.unit === 'meters') {
        return `${Math.floor(value)}m`;
      } else {
        return `${value.toFixed(2)} ${metric.unit}`;
      }
    } else if (typeof value === 'object') {
      return JSON.stringify(value, null, 2);
    } else {
      return String(value);
    }
  };

  // Get metric color based on type
  const getMetricColor = (metric: AnalyticsMetric) => {
    switch (metric.type) {
      case 'percentage':
        const value = parseFloat(metric.value);
        if (value >= 80) return 'text-success';
        if (value >= 60) return 'text-warning';
        return 'text-error';
      case 'average':
        return 'text-info';
      case 'counter':
        return 'text-primary';
      default:
        return 'text-neutral';
    }
  };

  // Render metric card
  const renderMetricCard = (metric: AnalyticsMetric) => (
    <div key={metric.metricId} className="card bg-base-200 shadow-lg">
      <div className="card-body p-4">
        <div className="flex justify-between items-start">
          <div>
            <h3 className="card-title text-sm font-bold">{metric.name}</h3>
            <p className="text-xs text-base-content/70">{metric.description}</p>
          </div>
          <div className="badge badge-outline badge-sm">{metric.category}</div>
        </div>
        
        <div className="mt-3">
          <div className={`text-2xl font-bold ${getMetricColor(metric)}`}>
            {formatMetricValue(metric)}
          </div>
          <div className="text-xs text-base-content/60 mt-1">
            {metric.dataPoints} data points • {new Date(metric.timestamp).toLocaleTimeString()}
          </div>
        </div>
      </div>
    </div>
  );

  // Render dashboard
  const renderDashboard = (dashboard: AnalyticsDashboard) => (
    <div key={dashboard.id} className="space-y-4">
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-xl font-bold">{dashboard.name}</h2>
          <p className="text-base-content/70">{dashboard.description}</p>
        </div>
        <div className="text-sm text-base-content/60">
          Refresh: {dashboard.refreshInterval / 1000}s
        </div>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {dashboard.metrics.map(renderMetricCard)}
      </div>
    </div>
  );

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-primary">Analytics Dashboard</h1>
          <p className="text-base-content/70">Real-time system analytics and performance metrics</p>
        </div>
        <div className="flex gap-2">
          <button 
            className="btn btn-primary btn-sm"
            onClick={() => loadAnalyticsData()}
            disabled={isLoading}
          >
            {isLoading ? (
              <span className="loading loading-spinner loading-sm"></span>
            ) : (
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
            )}
            Refresh
          </button>
        </div>
      </div>

      {/* Error Display */}
      {error && (
        <div className="alert alert-error">
          <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span>{error}</span>
        </div>
      )}

      {/* Dashboard Selection */}
      <div className="card bg-base-100 shadow-lg">
        <div className="card-body">
          <h3 className="card-title">Dashboard Selection</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {availableDashboards.map(dashboard => (
              <button
                key={dashboard.id}
                className={`card bg-base-200 hover:bg-base-300 transition-colors ${
                  selectedDashboard === dashboard.id ? 'ring-2 ring-primary' : ''
                }`}
                onClick={() => setSelectedDashboard(dashboard.id)}
              >
                <div className="card-body p-4">
                  <h4 className="font-bold">{dashboard.name}</h4>
                  <p className="text-sm text-base-content/70">{dashboard.description}</p>
                </div>
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Selected Dashboard */}
      {selectedDashboard && analyticsData.dashboards[selectedDashboard] && (
        <div className="card bg-base-100 shadow-lg">
          <div className="card-body">
            {renderDashboard(analyticsData.dashboards[selectedDashboard].data)}
          </div>
        </div>
      )}

      {/* Metric Selection */}
      <div className="card bg-base-100 shadow-lg">
        <div className="card-body">
          <h3 className="card-title">Individual Metrics</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {availableMetrics.map(metric => (
              <button
                key={metric.id}
                className={`card bg-base-200 hover:bg-base-300 transition-colors ${
                  selectedMetric === metric.id ? 'ring-2 ring-primary' : ''
                }`}
                onClick={() => setSelectedMetric(metric.id)}
              >
                <div className="card-body p-4">
                  <h4 className="font-bold">{metric.name}</h4>
                  <p className="text-sm text-base-content/70">{metric.category}</p>
                </div>
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Selected Metric */}
      {selectedMetric && analyticsData.metrics[selectedMetric] && (
        <div className="card bg-base-100 shadow-lg">
          <div className="card-body">
            <h3 className="card-title">Selected Metric</h3>
            {renderMetricCard(analyticsData.metrics[selectedMetric].data)}
          </div>
        </div>
      )}

      {/* Analytics Actions */}
      <div className="card bg-base-100 shadow-lg">
        <div className="card-body">
          <h3 className="card-title">Analytics Actions</h3>
          <div className="flex flex-wrap gap-4">
            <button
              className="btn btn-outline btn-sm"
              onClick={() => trackEvent('test', 'button_click', { source: 'analytics_tab' })}
            >
              Track Test Event
            </button>
            <button
              className="btn btn-outline btn-sm"
              onClick={() => trackEvent('player_behavior', 'ui_interaction', { tab: 'analytics' })}
            >
              Track UI Interaction
            </button>
            <button
              className="btn btn-outline btn-sm"
              onClick={() => requestDashboard('overview')}
            >
              Request Overview
            </button>
            <button
              className="btn btn-outline btn-sm"
              onClick={() => requestMetric('player_session_time')}
            >
              Request Session Time
            </button>
          </div>
        </div>
      </div>

      {/* Statistics */}
      <div className="card bg-base-100 shadow-lg">
        <div className="card-body">
          <h3 className="card-title">Analytics Statistics</h3>
          <div className="stats stats-horizontal shadow">
            <div className="stat">
              <div className="stat-title">Dashboards</div>
              <div className="stat-value">{Object.keys(analyticsData.dashboards).length}</div>
              <div className="stat-desc">Cached dashboards</div>
            </div>
            <div className="stat">
              <div className="stat-title">Metrics</div>
              <div className="stat-value">{Object.keys(analyticsData.metrics).length}</div>
              <div className="stat-desc">Cached metrics</div>
            </div>
            <div className="stat">
              <div className="stat-title">Last Update</div>
              <div className="stat-value">
                {analyticsData.lastUpdate > 0 
                  ? Math.floor((Date.now() - analyticsData.lastUpdate) / 1000) + 's'
                  : 'Never'
                }
              </div>
              <div className="stat-desc">Seconds ago</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}; 