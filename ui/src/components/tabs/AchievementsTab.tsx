import React, { useState, useEffect } from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/nui';

interface AchievementRequirement {
  type: string;
  target: number;
  description: string;
}

interface AchievementReward {
  type: string;
  amount?: number;
  value?: string;
}

interface AchievementMilestone {
  target: number;
  reward: AchievementReward;
}

interface Achievement {
  id: string;
  name: string;
  description: string;
  category: string;
  type: string;
  icon: string;
  color: string;
  requirements: AchievementRequirement[];
  rewards: AchievementReward[];
  milestones: AchievementMilestone[];
  maxProgress: number;
  customData: Record<string, any>;
  createdTime: number;
}

interface AchievementProgress {
  [achievementId: string]: number;
}

interface CompletedAchievement {
  completedTime: number;
  data?: Achievement;
}

interface AchievementRewards {
  influence?: number;
  experience?: number;
  money?: number;
  titles?: string[];
}

interface AchievementStatistics {
  total_achievements: number;
  total_influence: number;
  total_experience: number;
  total_money: number;
  categories_completed: Record<string, boolean>;
}

interface AchievementData {
  achievements: Record<string, Achievement>;
  progress: AchievementProgress;
  completed: Record<string, CompletedAchievement>;
  rewards: AchievementRewards;
  statistics: AchievementStatistics;
}

const AchievementsTab: React.FC = () => {
  const [achievementData, setAchievementData] = useState<AchievementData>({
    achievements: {},
    progress: {},
    completed: {},
    rewards: {},
    statistics: {
      total_achievements: 0,
      total_influence: 0,
      total_experience: 0,
      total_money: 0,
      categories_completed: {}
    }
  });
  const [activeCategory, setActiveCategory] = useState<string>('all');
  const [activeTab, setActiveTab] = useState<'overview' | 'categories' | 'progress' | 'rewards' | 'statistics'>('overview');
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');

  // Achievement categories
  const categories = {
    all: { name: 'All Achievements', icon: '🏆', color: '#ffff88' },
    combat: { name: 'Combat', icon: '⚔️', color: '#ff4444' },
    exploration: { name: 'Exploration', icon: '🗺️', color: '#4444ff' },
    teamwork: { name: 'Teamwork', icon: '🤝', color: '#ff8844' },
    leadership: { name: 'Leadership', icon: '👑', color: '#ffff44' },
    collection: { name: 'Collection', icon: '📦', color: '#44ff88' },
    social: { name: 'Social', icon: '💬', color: '#ff88ff' },
    mastery: { name: 'Mastery', icon: '🌟', color: '#ffff88' },
    special: { name: 'Special', icon: '💎', color: '#888888' }
  };

  // Load achievement data
  const loadAchievementData = async () => {
    try {
      const response = await fetchNui<{ success: boolean; data: AchievementData }>('achievement:get_data');
      if (response.success) {
        setAchievementData(response.data);
      }
    } catch (error) {
      console.error('Failed to load achievement data:', error);
    }
  };

  // NUI Event handlers
  useNuiEvent('achievement:progress_update', (data: { achievementId: string; progress: number }) => {
    setAchievementData(prev => ({
      ...prev,
      progress: { ...prev.progress, [data.achievementId]: data.progress }
    }));
  });

  useNuiEvent('achievement:completed', (data: { achievementId: string; achievement: Achievement }) => {
    setAchievementData(prev => ({
      ...prev,
      completed: {
        ...prev.completed,
        [data.achievementId]: {
          completedTime: Date.now(),
          data: data.achievement
        }
      }
    }));
  });

  useNuiEvent('achievement:milestone_completed', (data: { achievementId: string; milestone: AchievementMilestone }) => {
    // Update UI to show milestone completion
    console.log('Milestone completed:', data);
  });

  useNuiEvent('achievement:category_completed', (data: { category: string }) => {
    setAchievementData(prev => ({
      ...prev,
      statistics: {
        ...prev.statistics,
        categories_completed: {
          ...prev.statistics.categories_completed,
          [data.category]: true
        }
      }
    }));
  });

  useNuiEvent('achievement:chain_completed', (data: { chainId: string; chain: any }) => {
    // Update UI to show chain completion
    console.log('Chain completed:', data);
  });

  useNuiEvent('achievement:update', (data: AchievementData) => {
    setAchievementData(data);
  });

  // Helper functions
  const getAchievementProgress = (achievementId: string) => {
    return achievementData.progress[achievementId] || 0;
  };

  const isAchievementCompleted = (achievementId: string) => {
    return !!achievementData.completed[achievementId];
  };

  const getAchievementProgressPercentage = (achievement: Achievement) => {
    const progress = getAchievementProgress(achievement.id);
    return Math.min((progress / achievement.maxProgress) * 100, 100);
  };

  const getAchievementStatus = (achievement: Achievement) => {
    if (isAchievementCompleted(achievement.id)) {
      return 'completed';
    }
    const progress = getAchievementProgress(achievement.id);
    if (progress > 0) {
      return 'in_progress';
    }
    return 'locked';
  };

  const getAchievementStatusColor = (status: string) => {
    switch (status) {
      case 'completed': return 'text-success';
      case 'in_progress': return 'text-warning';
      case 'locked': return 'text-base-content/50';
      default: return 'text-base-content';
    }
  };

  const formatProgress = (progress: number, maxProgress: number) => {
    if (maxProgress >= 1000) {
      return `${(progress / 1000).toFixed(1)}k / ${(maxProgress / 1000).toFixed(1)}k`;
    }
    return `${progress} / ${maxProgress}`;
  };

  const formatTime = (timestamp: number) => {
    const date = new Date(timestamp);
    return date.toLocaleString();
  };

  const getFilteredAchievements = () => {
    let filtered = Object.values(achievementData.achievements);
    
    // Filter by category
    if (activeCategory !== 'all') {
      filtered = filtered.filter(achievement => achievement.category === activeCategory);
    }
    
    // Filter by search term
    if (searchTerm) {
      filtered = filtered.filter(achievement =>
        achievement.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        achievement.description.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }
    
    return filtered;
  };

  const getCategoryStats = (category: string) => {
    const categoryAchievements = Object.values(achievementData.achievements).filter(
      achievement => achievement.category === category
    );
    
    const completed = categoryAchievements.filter(achievement => 
      isAchievementCompleted(achievement.id)
    ).length;
    
    const total = categoryAchievements.length;
    const percentage = total > 0 ? (completed / total) * 100 : 0;
    
    return { completed, total, percentage };
  };

  // Load data on mount
  useEffect(() => {
    loadAchievementData();
  }, []);

  return (
    <div className="h-full flex flex-col bg-base-100">
      {/* Header */}
      <div className="flex justify-between items-center p-4 border-b border-base-300">
        <h2 className="text-2xl font-bold text-primary">Achievements</h2>
        <div className="flex gap-2">
          <button
            onClick={loadAchievementData}
            className="btn btn-ghost btn-sm"
            disabled={loading}
          >
            Refresh
          </button>
        </div>
      </div>

      {/* Navigation Tabs */}
      <div className="flex border-b border-base-300">
        {[
          { id: 'overview', label: 'Overview' },
          { id: 'categories', label: 'Categories' },
          { id: 'progress', label: 'Progress' },
          { id: 'rewards', label: 'Rewards' },
          { id: 'statistics', label: 'Statistics' }
        ].map(tab => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id as any)}
            className={`px-4 py-2 font-medium transition-colors ${
              activeTab === tab.id
                ? 'text-primary border-b-2 border-primary'
                : 'text-base-content hover:text-primary'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* Content */}
      <div className="flex-1 overflow-auto p-4">
        {loading && (
          <div className="flex justify-center items-center h-full">
            <span className="loading loading-spinner loading-lg"></span>
          </div>
        )}

        {!loading && (
          <>
            {/* Overview Tab */}
            {activeTab === 'overview' && (
              <div className="space-y-6">
                {/* Achievement Statistics */}
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  <div className="stat bg-base-200 rounded-lg">
                    <div className="stat-title">Total Achievements</div>
                    <div className="stat-value text-primary">
                      {achievementData.statistics.total_achievements}
                    </div>
                  </div>
                  <div className="stat bg-base-200 rounded-lg">
                    <div className="stat-title">Total Influence</div>
                    <div className="stat-value text-success">
                      {achievementData.statistics.total_influence.toLocaleString()}
                    </div>
                  </div>
                  <div className="stat bg-base-200 rounded-lg">
                    <div className="stat-title">Total Experience</div>
                    <div className="stat-value text-warning">
                      {achievementData.statistics.total_experience.toLocaleString()}
                    </div>
                  </div>
                  <div className="stat bg-base-200 rounded-lg">
                    <div className="stat-title">Total Money</div>
                    <div className="stat-value text-info">
                      ${achievementData.statistics.total_money.toLocaleString()}
                    </div>
                  </div>
                </div>

                {/* Category Progress */}
                <div className="card bg-base-200">
                  <div className="card-body">
                    <h3 className="card-title">Category Progress</h3>
                    <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                      {Object.entries(categories).map(([categoryId, category]) => {
                        if (categoryId === 'all') return null;
                        const stats = getCategoryStats(categoryId);
                        return (
                          <div key={categoryId} className="flex items-center gap-3">
                            <span className="text-2xl">{category.icon}</span>
                            <div className="flex-1">
                              <div className="font-medium">{category.name}</div>
                              <div className="text-sm text-base-content/70">
                                {stats.completed} / {stats.total}
                              </div>
                              <progress
                                className="progress progress-primary w-full"
                                value={stats.percentage}
                                max="100"
                              ></progress>
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  </div>
                </div>

                {/* Recent Achievements */}
                <div className="card bg-base-200">
                  <div className="card-body">
                    <h3 className="card-title">Recent Achievements</h3>
                    {Object.keys(achievementData.completed).length === 0 ? (
                      <p className="text-base-content/70">No achievements completed yet</p>
                    ) : (
                      <div className="space-y-2">
                        {Object.entries(achievementData.completed)
                          .slice(0, 5)
                          .map(([achievementId, completed]) => {
                            const achievement = achievementData.achievements[achievementId];
                            if (!achievement) return null;
                            return (
                              <div key={achievementId} className="flex items-center gap-3 p-2 bg-base-100 rounded">
                                <span className="text-xl">{achievement.icon}</span>
                                <div className="flex-1">
                                  <div className="font-medium">{achievement.name}</div>
                                  <div className="text-sm text-base-content/70">
                                    {formatTime(completed.completedTime)}
                                  </div>
                                </div>
                                <div className="text-success">✓</div>
                              </div>
                            );
                          })}
                      </div>
                    )}
                  </div>
                </div>
              </div>
            )}

            {/* Categories Tab */}
            {activeTab === 'categories' && (
              <div className="space-y-6">
                {/* Category Filter */}
                <div className="flex flex-wrap gap-2">
                  {Object.entries(categories).map(([categoryId, category]) => (
                    <button
                      key={categoryId}
                      onClick={() => setActiveCategory(categoryId)}
                      className={`btn btn-sm ${
                        activeCategory === categoryId ? 'btn-primary' : 'btn-ghost'
                      }`}
                    >
                      <span className="mr-2">{category.icon}</span>
                      {category.name}
                    </button>
                  ))}
                </div>

                {/* Search */}
                <div className="form-control">
                  <input
                    type="text"
                    placeholder="Search achievements..."
                    className="input input-bordered"
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                  />
                </div>

                {/* Achievements List */}
                <div className="grid gap-4">
                  {getFilteredAchievements().map(achievement => {
                    const status = getAchievementStatus(achievement);
                    const progress = getAchievementProgress(achievement.id);
                    const progressPercentage = getAchievementProgressPercentage(achievement);
                    
                    return (
                      <div key={achievement.id} className="card bg-base-200">
                        <div className="card-body">
                          <div className="flex items-start gap-4">
                            <div className="text-3xl">{achievement.icon}</div>
                            <div className="flex-1">
                              <div className="flex justify-between items-start">
                                <div>
                                  <h4 className={`font-semibold ${getAchievementStatusColor(status)}`}>
                                    {achievement.name}
                                  </h4>
                                  <p className="text-sm text-base-content/70 mt-1">
                                    {achievement.description}
                                  </p>
                                  <div className="text-xs text-base-content/50 mt-2">
                                    Category: {categories[achievement.category]?.name || achievement.category}
                                  </div>
                                </div>
                                <div className="text-right">
                                  <div className={`badge ${status === 'completed' ? 'badge-success' : status === 'in_progress' ? 'badge-warning' : 'badge-ghost'}`}>
                                    {status === 'completed' ? 'Completed' : status === 'in_progress' ? 'In Progress' : 'Locked'}
                                  </div>
                                </div>
                              </div>
                              
                              {/* Progress Bar */}
                              <div className="mt-4">
                                <div className="flex justify-between text-sm mb-1">
                                  <span>Progress</span>
                                  <span>{formatProgress(progress, achievement.maxProgress)}</span>
                                </div>
                                <progress
                                  className="progress progress-primary w-full"
                                  value={progressPercentage}
                                  max="100"
                                ></progress>
                              </div>
                              
                              {/* Requirements */}
                              <div className="mt-3">
                                <div className="text-sm font-medium mb-2">Requirements:</div>
                                {achievement.requirements.map((requirement, index) => (
                                  <div key={index} className="text-sm text-base-content/70">
                                    • {requirement.description}
                                  </div>
                                ))}
                              </div>
                              
                              {/* Rewards */}
                              {achievement.rewards.length > 0 && (
                                <div className="mt-3">
                                  <div className="text-sm font-medium mb-2">Rewards:</div>
                                  <div className="flex flex-wrap gap-2">
                                    {achievement.rewards.map((reward, index) => (
                                      <div key={index} className="badge badge-outline">
                                        {reward.type === 'influence' && `${reward.amount} Influence`}
                                        {reward.type === 'experience' && `${reward.amount} Experience`}
                                        {reward.type === 'money' && `$${reward.amount}`}
                                        {reward.type === 'special_title' && reward.value}
                                      </div>
                                    ))}
                                  </div>
                                </div>
                              )}
                              
                              {/* Milestones */}
                              {achievement.milestones.length > 0 && (
                                <div className="mt-3">
                                  <div className="text-sm font-medium mb-2">Milestones:</div>
                                  <div className="grid grid-cols-2 gap-2">
                                    {achievement.milestones.map((milestone, index) => (
                                      <div key={index} className="text-xs bg-base-100 p-2 rounded">
                                        <div className="font-medium">{milestone.target}</div>
                                        <div className="text-base-content/70">
                                          {milestone.reward.type === 'influence' && `${milestone.reward.amount} Influence`}
                                          {milestone.reward.type === 'experience' && `${milestone.reward.amount} Experience`}
                                          {milestone.reward.type === 'money' && `$${milestone.reward.amount}`}
                                        </div>
                                      </div>
                                    ))}
                                  </div>
                                </div>
                              )}
                            </div>
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            )}

            {/* Progress Tab */}
            {activeTab === 'progress' && (
              <div className="space-y-6">
                <h3 className="text-xl font-semibold">Achievement Progress</h3>
                
                <div className="grid gap-4">
                  {Object.entries(achievementData.progress).map(([achievementId, progress]) => {
                    const achievement = achievementData.achievements[achievementId];
                    if (!achievement) return null;
                    
                    const progressPercentage = getAchievementProgressPercentage(achievement);
                    const status = getAchievementStatus(achievement);
                    
                    return (
                      <div key={achievementId} className="card bg-base-200">
                        <div className="card-body">
                          <div className="flex items-center gap-4">
                            <span className="text-2xl">{achievement.icon}</span>
                            <div className="flex-1">
                              <div className="flex justify-between items-center">
                                <h4 className="font-semibold">{achievement.name}</h4>
                                <div className={`badge ${status === 'completed' ? 'badge-success' : 'badge-warning'}`}>
                                  {formatProgress(progress, achievement.maxProgress)}
                                </div>
                              </div>
                              <progress
                                className="progress progress-primary w-full mt-2"
                                value={progressPercentage}
                                max="100"
                              ></progress>
                            </div>
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            )}

            {/* Rewards Tab */}
            {activeTab === 'rewards' && (
              <div className="space-y-6">
                <h3 className="text-xl font-semibold">Achievement Rewards</h3>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {/* Total Rewards */}
                  <div className="card bg-base-200">
                    <div className="card-body">
                      <h4 className="card-title">Total Rewards Earned</h4>
                      <div className="space-y-3">
                        <div className="flex justify-between">
                          <span>Influence:</span>
                          <span className="font-semibold text-success">
                            {achievementData.statistics.total_influence.toLocaleString()}
                          </span>
                        </div>
                        <div className="flex justify-between">
                          <span>Experience:</span>
                          <span className="font-semibold text-warning">
                            {achievementData.statistics.total_experience.toLocaleString()}
                          </span>
                        </div>
                        <div className="flex justify-between">
                          <span>Money:</span>
                          <span className="font-semibold text-info">
                            ${achievementData.statistics.total_money.toLocaleString()}
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Titles */}
                  <div className="card bg-base-200">
                    <div className="card-body">
                      <h4 className="card-title">Earned Titles</h4>
                      {achievementData.rewards.titles && achievementData.rewards.titles.length > 0 ? (
                        <div className="space-y-2">
                          {achievementData.rewards.titles.map((title, index) => (
                            <div key={index} className="badge badge-primary badge-lg">
                              {title}
                            </div>
                          ))}
                        </div>
                      ) : (
                        <p className="text-base-content/70">No titles earned yet</p>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* Statistics Tab */}
            {activeTab === 'statistics' && (
              <div className="space-y-6">
                <h3 className="text-xl font-semibold">Achievement Statistics</h3>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {/* Overall Statistics */}
                  <div className="card bg-base-200">
                    <div className="card-body">
                      <h4 className="card-title">Overall Statistics</h4>
                      <div className="space-y-3">
                        <div className="flex justify-between">
                          <span>Total Achievements:</span>
                          <span className="font-semibold">{achievementData.statistics.total_achievements}</span>
                        </div>
                        <div className="flex justify-between">
                          <span>Completed:</span>
                          <span className="font-semibold text-success">
                            {Object.keys(achievementData.completed).length}
                          </span>
                        </div>
                        <div className="flex justify-between">
                          <span>In Progress:</span>
                          <span className="font-semibold text-warning">
                            {Object.keys(achievementData.progress).length}
                          </span>
                        </div>
                        <div className="flex justify-between">
                          <span>Completion Rate:</span>
                          <span className="font-semibold">
                            {achievementData.statistics.total_achievements > 0 
                              ? Math.round((Object.keys(achievementData.completed).length / achievementData.statistics.total_achievements) * 100)
                              : 0}%
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Category Completion */}
                  <div className="card bg-base-200">
                    <div className="card-body">
                      <h4 className="card-title">Category Completion</h4>
                      <div className="space-y-3">
                        {Object.entries(categories).map(([categoryId, category]) => {
                          if (categoryId === 'all') return null;
                          const stats = getCategoryStats(categoryId);
                          const isCompleted = achievementData.statistics.categories_completed[categoryId];
                          
                          return (
                            <div key={categoryId} className="flex items-center justify-between">
                              <div className="flex items-center gap-2">
                                <span>{category.icon}</span>
                                <span>{category.name}</span>
                                {isCompleted && <span className="text-success">✓</span>}
                              </div>
                              <span className="font-semibold">
                                {stats.completed}/{stats.total}
                              </span>
                            </div>
                          );
                        })}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
};

export default AchievementsTab; 