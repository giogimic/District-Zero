import React, { useState, useEffect } from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/nui';

interface TeamMember {
  id: string;
  role: string;
  joinTime: number;
  lastActivity: number;
  stats: {
    captures: number;
    missions: number;
    influence: number;
    experience: number;
  };
}

interface TeamStats {
  captures: number;
  missions: number;
  influence: number;
  experience: number;
  wars_won: number;
  wars_lost: number;
  challenges_won: number;
  challenges_lost: number;
  total_members: number;
  current_members: number;
}

interface Team {
  id: string;
  name: string;
  description: string;
  template: string;
  leader: string;
  officers: Record<string, any>;
  veterans: Record<string, any>;
  members: Record<string, TeamMember>;
  recruits: Record<string, any>;
  maxMembers: number;
  maxOfficers: number;
  maxVeterans: number;
  requirements: {
    minLevel: number;
    minMembers: number;
  };
  permissions: {
    inviteOnly: boolean;
    autoAccept: boolean;
    requireApproval: boolean;
  };
  progression: {
    experienceMultiplier: number;
    influenceMultiplier: number;
    rewardMultiplier: number;
  };
  state: string;
  createdTime: number;
  lastActivity: number;
  stats: TeamStats;
  funds: number;
  level: number;
  customData: Record<string, any>;
}

interface TeamInvitation {
  teamId: string;
  teamName: string;
  inviterId: string;
  inviterName: string;
  role: string;
  time: number;
}

interface TeamChallenge {
  id: string;
  name: string;
  description: string;
  type: string;
  template: string;
  teams: string[];
  state: string;
  startTime: number;
  endTime: number;
  duration: number;
  requirements: {
    minTeamSize: number;
    minTeamLevel: number;
  };
  objectives: Array<{
    id: string;
    type: string;
    name: string;
    description: string;
    targetCount: number;
    required: boolean;
    rewards: {
      influence: number;
      experience: number;
    };
    completed: boolean;
    progress: number;
  }>;
  rewards: {
    first: { influence: number; experience: number; money: number };
    second: { influence: number; experience: number; money: number };
    third: { influence: number; experience: number; money: number };
  };
  participants: Record<string, {
    joinTime: number;
    progress: Record<string, number>;
    score: number;
  }>;
  progress: Record<string, any>;
  results: Array<{ id: string; score: number }>;
  customData: Record<string, any>;
}

interface TeamWar {
  id: string;
  attacker: string;
  defender: string;
  reason: string;
  state: string;
  declaredTime: number;
  startTime: number;
  endTime: number;
  duration: number;
  stats: {
    attacker_score: number;
    defender_score: number;
    attacker_captures: number;
    defender_captures: number;
    attacker_eliminations: number;
    defender_eliminations: number;
  };
  winner: string | null;
}

interface Alliance {
  id: string;
  team1: string;
  team2: string;
  proposer: string;
  terms: Record<string, any>;
  state: string;
  proposedTime: number;
  acceptedTime: number;
  dissolvedTime: number;
}

interface AdvancedTeamData {
  currentTeam: Team | null;
  invitations: Record<string, TeamInvitation>;
  challenges: Record<string, TeamChallenge>;
  wars: Record<string, TeamWar>;
  alliances: Record<string, Alliance>;
  stats: Record<string, any>;
}

const TeamsTab: React.FC = () => {
  const [teamData, setTeamData] = useState<AdvancedTeamData>({
    currentTeam: null,
    invitations: {},
    challenges: {},
    wars: {},
    alliances: {},
    stats: {}
  });
  const [activeTab, setActiveTab] = useState<'overview' | 'members' | 'challenges' | 'wars' | 'alliances' | 'invitations'>('overview');
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [showInviteModal, setShowInviteModal] = useState(false);
  const [showPromoteModal, setShowPromoteModal] = useState(false);
  const [showWarModal, setShowWarModal] = useState(false);
  const [loading, setLoading] = useState(false);

  // Form states
  const [createForm, setCreateForm] = useState({
    template: 'standard',
    name: '',
    description: ''
  });
  const [inviteForm, setInviteForm] = useState({
    targetPlayerId: '',
    role: 'member'
  });
  const [promoteForm, setPromoteForm] = useState({
    targetPlayerId: '',
    newRole: 'veteran'
  });
  const [warForm, setWarForm] = useState({
    targetTeamId: '',
    reason: ''
  });

  // Load team data
  const loadTeamData = async () => {
    try {
      const response = await fetchNui<{ success: boolean; data: AdvancedTeamData }>('team:get_advanced_data');
      if (response.success) {
        setTeamData(response.data);
      }
    } catch (error) {
      console.error('Failed to load team data:', error);
    }
  };

  // NUI Event handlers
  useNuiEvent('team:update', (data: { team: Team }) => {
    setTeamData(prev => ({ ...prev, currentTeam: data.team }));
  });

  useNuiEvent('team:invitation', (data: { invitation: TeamInvitation }) => {
    setTeamData(prev => ({
      ...prev,
      invitations: { ...prev.invitations, [data.invitation.teamId]: data.invitation }
    }));
  });

  useNuiEvent('team:challenge_available', (data: { challenge: TeamChallenge }) => {
    setTeamData(prev => ({
      ...prev,
      challenges: { ...prev.challenges, [data.challenge.id]: data.challenge }
    }));
  });

  useNuiEvent('team:challenge_started', (data: { challenge: TeamChallenge }) => {
    setTeamData(prev => ({
      ...prev,
      challenges: { ...prev.challenges, [data.challenge.id]: data.challenge }
    }));
  });

  useNuiEvent('team:war_declared', (data: { war: TeamWar }) => {
    setTeamData(prev => ({
      ...prev,
      wars: { ...prev.wars, [data.war.id]: data.war }
    }));
  });

  // Team actions
  const createTeam = async () => {
    if (!createForm.name.trim()) return;
    
    setLoading(true);
    try {
      const response = await fetchNui('team:create_advanced', createForm);
      if (response.success) {
        setShowCreateModal(false);
        setCreateForm({ template: 'standard', name: '', description: '' });
        await loadTeamData();
      }
    } catch (error) {
      console.error('Failed to create team:', error);
    } finally {
      setLoading(false);
    }
  };

  const invitePlayer = async () => {
    if (!inviteForm.targetPlayerId.trim()) return;
    
    setLoading(true);
    try {
      const response = await fetchNui('team:invite', inviteForm);
      if (response.success) {
        setShowInviteModal(false);
        setInviteForm({ targetPlayerId: '', role: 'member' });
      }
    } catch (error) {
      console.error('Failed to invite player:', error);
    } finally {
      setLoading(false);
    }
  };

  const acceptInvitation = async (teamId: string, role: string) => {
    setLoading(true);
    try {
      const response = await fetchNui('team:accept_invitation', { teamId, role });
      if (response.success) {
        await loadTeamData();
      }
    } catch (error) {
      console.error('Failed to accept invitation:', error);
    } finally {
      setLoading(false);
    }
  };

  const promoteMember = async () => {
    if (!promoteForm.targetPlayerId.trim()) return;
    
    setLoading(true);
    try {
      const response = await fetchNui('team:promote', promoteForm);
      if (response.success) {
        setShowPromoteModal(false);
        setPromoteForm({ targetPlayerId: '', newRole: 'veteran' });
        await loadTeamData();
      }
    } catch (error) {
      console.error('Failed to promote member:', error);
    } finally {
      setLoading(false);
    }
  };

  const kickMember = async (playerId: string) => {
    if (!confirm('Are you sure you want to kick this member?')) return;
    
    setLoading(true);
    try {
      const response = await fetchNui('team:kick', { targetPlayerId: playerId });
      if (response.success) {
        await loadTeamData();
      }
    } catch (error) {
      console.error('Failed to kick member:', error);
    } finally {
      setLoading(false);
    }
  };

  const declareWar = async () => {
    if (!warForm.targetTeamId.trim()) return;
    
    setLoading(true);
    try {
      const response = await fetchNui('team:declare_war', warForm);
      if (response.success) {
        setShowWarModal(false);
        setWarForm({ targetTeamId: '', reason: '' });
        await loadTeamData();
      }
    } catch (error) {
      console.error('Failed to declare war:', error);
    } finally {
      setLoading(false);
    }
  };

  const joinChallenge = async (challengeId: string) => {
    setLoading(true);
    try {
      const response = await fetchNui('team:join_challenge', { challengeId });
      if (response.success) {
        await loadTeamData();
      }
    } catch (error) {
      console.error('Failed to join challenge:', error);
    } finally {
      setLoading(false);
    }
  };

  // Load data on mount
  useEffect(() => {
    loadTeamData();
  }, []);

  // Helper functions
  const getRoleColor = (role: string) => {
    switch (role) {
      case 'leader': return 'text-red-500';
      case 'officer': return 'text-orange-500';
      case 'veteran': return 'text-yellow-500';
      case 'member': return 'text-green-500';
      case 'recruit': return 'text-blue-500';
      default: return 'text-gray-500';
    }
  };

  const formatTime = (timestamp: number) => {
    const date = new Date(timestamp);
    return date.toLocaleString();
  };

  const getChallengeStatus = (challenge: TeamChallenge) => {
    if (challenge.state === 'pending') return 'Pending';
    if (challenge.state === 'active') return 'Active';
    if (challenge.state === 'completed') return 'Completed';
    return 'Unknown';
  };

  const getWarStatus = (war: TeamWar) => {
    if (war.state === 'declared') return 'Declared';
    if (war.state === 'active') return 'Active';
    if (war.state === 'ended') return 'Ended';
    return 'Unknown';
  };

  return (
    <div className="h-full flex flex-col bg-base-100">
      {/* Header */}
      <div className="flex justify-between items-center p-4 border-b border-base-300">
        <h2 className="text-2xl font-bold text-primary">Advanced Teams</h2>
        <div className="flex gap-2">
          {!teamData.currentTeam && (
            <button
              onClick={() => setShowCreateModal(true)}
              className="btn btn-primary btn-sm"
              disabled={loading}
            >
              Create Team
            </button>
          )}
          <button
            onClick={loadTeamData}
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
          { id: 'members', label: 'Members' },
          { id: 'challenges', label: 'Challenges' },
          { id: 'wars', label: 'Wars' },
          { id: 'alliances', label: 'Alliances' },
          { id: 'invitations', label: 'Invitations' }
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
                {teamData.currentTeam ? (
                  <>
                    {/* Team Info */}
                    <div className="card bg-base-200">
                      <div className="card-body">
                        <h3 className="card-title text-primary">{teamData.currentTeam.name}</h3>
                        <p className="text-base-content/70">{teamData.currentTeam.description}</p>
                        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-4">
                          <div className="stat">
                            <div className="stat-title">Level</div>
                            <div className="stat-value text-primary">{teamData.currentTeam.level}</div>
                          </div>
                          <div className="stat">
                            <div className="stat-title">Members</div>
                            <div className="stat-value">{teamData.currentTeam.stats.current_members}/{teamData.currentTeam.maxMembers}</div>
                          </div>
                          <div className="stat">
                            <div className="stat-title">Funds</div>
                            <div className="stat-value">${teamData.currentTeam.funds.toLocaleString()}</div>
                          </div>
                          <div className="stat">
                            <div className="stat-title">Influence</div>
                            <div className="stat-value">{teamData.currentTeam.stats.influence}</div>
                          </div>
                        </div>
                      </div>
                    </div>

                    {/* Quick Actions */}
                    <div className="card bg-base-200">
                      <div className="card-body">
                        <h3 className="card-title">Quick Actions</h3>
                        <div className="flex flex-wrap gap-2">
                          <button
                            onClick={() => setShowInviteModal(true)}
                            className="btn btn-primary btn-sm"
                          >
                            Invite Player
                          </button>
                          <button
                            onClick={() => setShowPromoteModal(true)}
                            className="btn btn-secondary btn-sm"
                          >
                            Promote Member
                          </button>
                          <button
                            onClick={() => setShowWarModal(true)}
                            className="btn btn-accent btn-sm"
                          >
                            Declare War
                          </button>
                        </div>
                      </div>
                    </div>

                    {/* Team Stats */}
                    <div className="card bg-base-200">
                      <div className="card-body">
                        <h3 className="card-title">Team Statistics</h3>
                        <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                          <div className="stat">
                            <div className="stat-title">Captures</div>
                            <div className="stat-value">{teamData.currentTeam.stats.captures}</div>
                          </div>
                          <div className="stat">
                            <div className="stat-title">Missions</div>
                            <div className="stat-value">{teamData.currentTeam.stats.missions}</div>
                          </div>
                          <div className="stat">
                            <div className="stat-title">Experience</div>
                            <div className="stat-value">{teamData.currentTeam.stats.experience}</div>
                          </div>
                          <div className="stat">
                            <div className="stat-title">Wars Won</div>
                            <div className="stat-value text-success">{teamData.currentTeam.stats.wars_won}</div>
                          </div>
                          <div className="stat">
                            <div className="stat-title">Wars Lost</div>
                            <div className="stat-value text-error">{teamData.currentTeam.stats.wars_lost}</div>
                          </div>
                          <div className="stat">
                            <div className="stat-title">Challenges Won</div>
                            <div className="stat-value text-success">{teamData.currentTeam.stats.challenges_won}</div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </>
                ) : (
                  <div className="text-center py-8">
                    <h3 className="text-xl font-semibold mb-4">No Team</h3>
                    <p className="text-base-content/70 mb-4">
                      You are not currently in a team. Create one to get started!
                    </p>
                    <button
                      onClick={() => setShowCreateModal(true)}
                      className="btn btn-primary"
                    >
                      Create Team
                    </button>
                  </div>
                )}
              </div>
            )}

            {/* Members Tab */}
            {activeTab === 'members' && teamData.currentTeam && (
              <div className="space-y-4">
                <div className="flex justify-between items-center">
                  <h3 className="text-xl font-semibold">Team Members</h3>
                  <button
                    onClick={() => setShowInviteModal(true)}
                    className="btn btn-primary btn-sm"
                  >
                    Invite Player
                  </button>
                </div>
                
                <div className="grid gap-4">
                  {Object.entries(teamData.currentTeam.members).map(([playerId, member]) => (
                    <div key={playerId} className="card bg-base-200">
                      <div className="card-body">
                        <div className="flex justify-between items-center">
                          <div>
                            <h4 className="font-semibold">Player {playerId}</h4>
                            <p className={`text-sm ${getRoleColor(member.role)}`}>
                              {member.role.charAt(0).toUpperCase() + member.role.slice(1)}
                            </p>
                            <p className="text-xs text-base-content/70">
                              Joined: {formatTime(member.joinTime)}
                            </p>
                          </div>
                          <div className="flex gap-2">
                            <button
                              onClick={() => {
                                setPromoteForm({ targetPlayerId: playerId, newRole: 'veteran' });
                                setShowPromoteModal(true);
                              }}
                              className="btn btn-secondary btn-xs"
                              disabled={member.role === 'leader'}
                            >
                              Promote
                            </button>
                            <button
                              onClick={() => kickMember(playerId)}
                              className="btn btn-error btn-xs"
                              disabled={member.role === 'leader'}
                            >
                              Kick
                            </button>
                          </div>
                        </div>
                        <div className="grid grid-cols-3 gap-2 mt-2 text-xs">
                          <div>Captures: {member.stats.captures}</div>
                          <div>Missions: {member.stats.missions}</div>
                          <div>Influence: {member.stats.influence}</div>
                        </div>
              </div>
            </div>
          ))}
        </div>
      </div>
            )}

            {/* Challenges Tab */}
            {activeTab === 'challenges' && (
              <div className="space-y-4">
                <h3 className="text-xl font-semibold">Team Challenges</h3>
                
                {Object.keys(teamData.challenges).length === 0 ? (
                  <div className="text-center py-8">
                    <p className="text-base-content/70">No active challenges</p>
                  </div>
                ) : (
                  <div className="grid gap-4">
                    {Object.entries(teamData.challenges).map(([challengeId, challenge]) => (
                      <div key={challengeId} className="card bg-base-200">
                        <div className="card-body">
                          <div className="flex justify-between items-start">
            <div>
                              <h4 className="font-semibold">{challenge.name}</h4>
                              <p className="text-sm text-base-content/70">{challenge.description}</p>
                              <p className="text-xs text-base-content/50">
                                Status: {getChallengeStatus(challenge)}
                              </p>
                            </div>
                            {challenge.state === 'pending' && teamData.currentTeam && (
                              <button
                                onClick={() => joinChallenge(challengeId)}
                                className="btn btn-primary btn-sm"
                              >
                                Join
                              </button>
                            )}
                          </div>
                          
                          {challenge.objectives && (
                            <div className="mt-4">
                              <h5 className="font-medium mb-2">Objectives:</h5>
              <div className="space-y-2">
                                {challenge.objectives.map((objective, index) => (
                                  <div key={index} className="flex justify-between items-center">
                                    <span className="text-sm">{objective.name}</span>
                                    <div className="flex items-center gap-2">
                                      <progress
                                        className="progress progress-primary w-20"
                                        value={objective.progress}
                                        max={objective.targetCount}
                                      ></progress>
                                      <span className="text-xs">
                                        {objective.progress}/{objective.targetCount}
                                      </span>
                                    </div>
                                  </div>
                                ))}
                              </div>
                            </div>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}

            {/* Wars Tab */}
            {activeTab === 'wars' && (
              <div className="space-y-4">
                <div className="flex justify-between items-center">
                  <h3 className="text-xl font-semibold">Team Wars</h3>
                  {teamData.currentTeam && (
                    <button
                      onClick={() => setShowWarModal(true)}
                      className="btn btn-accent btn-sm"
                    >
                      Declare War
                    </button>
                  )}
                </div>
                
                {Object.keys(teamData.wars).length === 0 ? (
                  <div className="text-center py-8">
                    <p className="text-base-content/70">No active wars</p>
                  </div>
                ) : (
                  <div className="grid gap-4">
                    {Object.entries(teamData.wars).map(([warId, war]) => (
                      <div key={warId} className="card bg-base-200">
                        <div className="card-body">
                          <div className="flex justify-between items-start">
                            <div>
                              <h4 className="font-semibold">
                                {war.attacker} vs {war.defender}
                              </h4>
                              <p className="text-sm text-base-content/70">{war.reason}</p>
                              <p className="text-xs text-base-content/50">
                                Status: {getWarStatus(war)}
                              </p>
                            </div>
                          </div>
                          
                          <div className="grid grid-cols-2 gap-4 mt-4">
                            <div>
                              <h5 className="font-medium text-sm">Attacker Score</h5>
                              <p className="text-lg font-bold">{war.stats.attacker_score}</p>
                            </div>
                            <div>
                              <h5 className="font-medium text-sm">Defender Score</h5>
                              <p className="text-lg font-bold">{war.stats.defender_score}</p>
                            </div>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}

            {/* Alliances Tab */}
            {activeTab === 'alliances' && (
              <div className="space-y-4">
                <h3 className="text-xl font-semibold">Alliances</h3>
                
                {Object.keys(teamData.alliances).length === 0 ? (
                  <div className="text-center py-8">
                    <p className="text-base-content/70">No alliances</p>
                  </div>
                ) : (
                  <div className="grid gap-4">
                    {Object.entries(teamData.alliances).map(([allianceId, alliance]) => (
                      <div key={allianceId} className="card bg-base-200">
                        <div className="card-body">
                          <h4 className="font-semibold">
                            {alliance.team1} & {alliance.team2}
                          </h4>
                          <p className="text-sm text-base-content/70">
                            Status: {alliance.state.charAt(0).toUpperCase() + alliance.state.slice(1)}
                          </p>
                          <p className="text-xs text-base-content/50">
                            Proposed: {formatTime(alliance.proposedTime)}
                          </p>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}

            {/* Invitations Tab */}
            {activeTab === 'invitations' && (
              <div className="space-y-4">
                <h3 className="text-xl font-semibold">Team Invitations</h3>
                
                {Object.keys(teamData.invitations).length === 0 ? (
                  <div className="text-center py-8">
                    <p className="text-base-content/70">No pending invitations</p>
                  </div>
                ) : (
                  <div className="grid gap-4">
                    {Object.entries(teamData.invitations).map(([teamId, invitation]) => (
                      <div key={teamId} className="card bg-base-200">
                        <div className="card-body">
                          <div className="flex justify-between items-center">
                            <div>
                              <h4 className="font-semibold">{invitation.teamName}</h4>
                              <p className="text-sm text-base-content/70">
                                Invited by: {invitation.inviterName}
                              </p>
                              <p className="text-xs text-base-content/50">
                                Role: {invitation.role.charAt(0).toUpperCase() + invitation.role.slice(1)}
                              </p>
                            </div>
                            <div className="flex gap-2">
                              <button
                                onClick={() => acceptInvitation(teamId, invitation.role)}
                                className="btn btn-primary btn-sm"
                              >
                                Accept
                              </button>
                              <button
                                onClick={() => {
                                  // Remove invitation
                                  setTeamData(prev => {
                                    const newInvitations = { ...prev.invitations };
                                    delete newInvitations[teamId];
                                    return { ...prev, invitations: newInvitations };
                                  });
                                }}
                                className="btn btn-ghost btn-sm"
                              >
                                Decline
                              </button>
                            </div>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}
          </>
        )}
      </div>

      {/* Create Team Modal */}
      {showCreateModal && (
        <div className="modal modal-open">
          <div className="modal-box">
            <h3 className="font-bold text-lg mb-4">Create Team</h3>
            <div className="space-y-4">
              <div>
                <label className="label">
                  <span className="label-text">Template</span>
                </label>
                <select
                  className="select select-bordered w-full"
                  value={createForm.template}
                  onChange={(e) => setCreateForm(prev => ({ ...prev, template: e.target.value }))}
                >
                  <option value="standard">Standard Team</option>
                  <option value="elite">Elite Team</option>
                  <option value="mercenary">Mercenary Team</option>
                </select>
              </div>
              <div>
                <label className="label">
                  <span className="label-text">Team Name</span>
                </label>
                <input
                  type="text"
                  className="input input-bordered w-full"
                  value={createForm.name}
                  onChange={(e) => setCreateForm(prev => ({ ...prev, name: e.target.value }))}
                  placeholder="Enter team name"
                />
              </div>
              <div>
                <label className="label">
                  <span className="label-text">Description</span>
                </label>
                <textarea
                  className="textarea textarea-bordered w-full"
                  value={createForm.description}
                  onChange={(e) => setCreateForm(prev => ({ ...prev, description: e.target.value }))}
                  placeholder="Enter team description"
                  rows={3}
                />
              </div>
            </div>
            <div className="modal-action">
              <button
                onClick={() => setShowCreateModal(false)}
                className="btn btn-ghost"
              >
                Cancel
              </button>
              <button
                onClick={createTeam}
                className="btn btn-primary"
                disabled={loading || !createForm.name.trim()}
              >
                {loading ? <span className="loading loading-spinner loading-sm"></span> : 'Create'}
              </button>
            </div>
          </div>
                </div>
      )}

      {/* Invite Player Modal */}
      {showInviteModal && (
        <div className="modal modal-open">
          <div className="modal-box">
            <h3 className="font-bold text-lg mb-4">Invite Player</h3>
            <div className="space-y-4">
              <div>
                <label className="label">
                  <span className="label-text">Player ID</span>
                </label>
                <input
                  type="number"
                  className="input input-bordered w-full"
                  value={inviteForm.targetPlayerId}
                  onChange={(e) => setInviteForm(prev => ({ ...prev, targetPlayerId: e.target.value }))}
                  placeholder="Enter player ID"
                />
                </div>
              <div>
                <label className="label">
                  <span className="label-text">Role</span>
                </label>
                <select
                  className="select select-bordered w-full"
                  value={inviteForm.role}
                  onChange={(e) => setInviteForm(prev => ({ ...prev, role: e.target.value }))}
                >
                  <option value="member">Member</option>
                  <option value="veteran">Veteran</option>
                  <option value="officer">Officer</option>
                </select>
              </div>
            </div>
            <div className="modal-action">
              <button
                onClick={() => setShowInviteModal(false)}
                className="btn btn-ghost"
              >
                Cancel
              </button>
              <button
                onClick={invitePlayer}
                className="btn btn-primary"
                disabled={loading || !inviteForm.targetPlayerId.trim()}
              >
                {loading ? <span className="loading loading-spinner loading-sm"></span> : 'Invite'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Promote Member Modal */}
      {showPromoteModal && (
        <div className="modal modal-open">
          <div className="modal-box">
            <h3 className="font-bold text-lg mb-4">Promote Member</h3>
            <div className="space-y-4">
              <div>
                <label className="label">
                  <span className="label-text">Player ID</span>
                </label>
                <input
                  type="number"
                  className="input input-bordered w-full"
                  value={promoteForm.targetPlayerId}
                  onChange={(e) => setPromoteForm(prev => ({ ...prev, targetPlayerId: e.target.value }))}
                  placeholder="Enter player ID"
                />
              </div>
            <div>
                <label className="label">
                  <span className="label-text">New Role</span>
                </label>
                <select
                  className="select select-bordered w-full"
                  value={promoteForm.newRole}
                  onChange={(e) => setPromoteForm(prev => ({ ...prev, newRole: e.target.value }))}
                >
                  <option value="veteran">Veteran</option>
                  <option value="officer">Officer</option>
                </select>
              </div>
            </div>
            <div className="modal-action">
              <button
                onClick={() => setShowPromoteModal(false)}
                className="btn btn-ghost"
              >
                Cancel
              </button>
              <button
                onClick={promoteMember}
                className="btn btn-primary"
                disabled={loading || !promoteForm.targetPlayerId.trim()}
              >
                {loading ? <span className="loading loading-spinner loading-sm"></span> : 'Promote'}
              </button>
            </div>
                </div>
                </div>
      )}

      {/* Declare War Modal */}
      {showWarModal && (
        <div className="modal modal-open">
          <div className="modal-box">
            <h3 className="font-bold text-lg mb-4">Declare War</h3>
            <div className="space-y-4">
              <div>
                <label className="label">
                  <span className="label-text">Target Team ID</span>
                </label>
                <input
                  type="text"
                  className="input input-bordered w-full"
                  value={warForm.targetTeamId}
                  onChange={(e) => setWarForm(prev => ({ ...prev, targetTeamId: e.target.value }))}
                  placeholder="Enter team ID"
                />
                </div>
              <div>
                <label className="label">
                  <span className="label-text">Reason</span>
                </label>
                <textarea
                  className="textarea textarea-bordered w-full"
                  value={warForm.reason}
                  onChange={(e) => setWarForm(prev => ({ ...prev, reason: e.target.value }))}
                  placeholder="Enter war reason"
                  rows={3}
                />
              </div>
            </div>
            <div className="modal-action">
              <button
                onClick={() => setShowWarModal(false)}
                className="btn btn-ghost"
              >
                Cancel
              </button>
              <button
                onClick={declareWar}
                className="btn btn-accent"
                disabled={loading || !warForm.targetTeamId.trim()}
              >
                {loading ? <span className="loading loading-spinner loading-sm"></span> : 'Declare War'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default TeamsTab; 