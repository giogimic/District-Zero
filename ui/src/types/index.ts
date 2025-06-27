// Core types for District Zero UI

export interface District {
  id: string
  name: string
  description: string
  influence_pvp: number
  influence_pve: number
  last_updated: string
  zones: DistrictZone[]
  controlPoints: ControlPoint[]
}

export interface DistrictZone {
  name: string
  coords: [number, number, number]
  radius: number
  isSafeZone: boolean
}

export interface ControlPoint {
  id: number
  district_id: string
  name: string
  coords: [number, number, number]
  radius: number
  influence: number
  current_team: 'pvp' | 'pve' | 'neutral'
  last_captured: string | null
}

export interface Mission {
  id: string
  title: string
  description: string
  type: 'pvp' | 'pve'
  district_id: string
  reward: number
  objectives: MissionObjective[]
  active: boolean
  requirements?: MissionRequirements
}

export interface MissionObjective {
  id: number
  type: 'capture' | 'deliver' | 'eliminate' | 'escort' | 'hack'
  description: string
  target?: string
  location?: [number, number, number]
  completed: boolean
  progress: number
  max_progress: number
}

export interface MissionRequirements {
  level?: number
  items?: Array<{
    name: string
    count: number
  }>
  team?: 'pvp' | 'pve'
}

export interface MissionProgress {
  id: number
  mission_id: string
  citizenid: string
  status: 'active' | 'completed' | 'failed'
  started_at: string
  completed_at: string | null
  objectives_completed: number[]
}

export interface Player {
  citizenid: string
  team: 'pvp' | 'pve' | null
  current_district: string | null
  last_updated: string
  stats?: PlayerStats
}

export interface PlayerStats {
  missions_completed: number
  missions_failed: number
  districts_captured: number
  control_points_captured: number
  total_rewards: number
  playtime_hours: number
}

export interface Team {
  id: 'pvp' | 'pve'
  name: string
  description: string
  color: string
  members: number
  influence: number
}

export interface TeamBalance {
  pvp: {
    members: number
    influence: number
    districts_controlled: number
  }
  pve: {
    members: number
    influence: number
    districts_controlled: number
  }
}

// UI State Types
export interface UIState {
  isOpen: boolean
  currentTab: 'dashboard' | 'districts' | 'missions' | 'teams' | 'analytics' | 'settings'
  currentDistrict: District | null
  currentTeam: 'pvp' | 'pve' | null
  currentMission: Mission | null
  notifications: Notification[]
  loading: boolean
  error: string | null
}

export interface Notification {
  id: string
  type: 'success' | 'error' | 'warning' | 'info'
  message: string
  title?: string
  duration?: number
  timestamp: number
}

// Event Types
export interface NUIEvent {
  type: string
  data?: any
}

export interface NUICallback {
  success: boolean
  data?: any
  error?: string
}

// API Response Types
export interface UIData {
  districts: District[]
  missions: Mission[]
  teams: Team[]
  currentTeam: 'pvp' | 'pve' | null
  currentDistrict: District | null
  playerStats: PlayerStats | null
  teamBalance: TeamBalance | null
}

// Component Props Types
export interface DistrictCardProps {
  district: District
  isCurrent: boolean
  onSelect: (district: District) => void
}

export interface MissionCardProps {
  mission: Mission
  onAccept: (mission: Mission) => void
  disabled?: boolean
}

export interface TeamSelectorProps {
  currentTeam: 'pvp' | 'pve' | null
  onSelect: (team: 'pvp' | 'pve') => void
  balance: TeamBalance | null
}

export interface NotificationProps {
  notification: Notification
  onDismiss: (id: string) => void
}

// Chart Data Types
export interface InfluenceData {
  district: string
  pvp: number
  pve: number
  timestamp: string
}

export interface MissionStats {
  completed: number
  failed: number
  active: number
  total_rewards: number
}

export interface TeamStats {
  members: number
  influence: number
  districts_controlled: number
  missions_completed: number
}

// Utility Types
export type TeamType = 'pvp' | 'pve'
export type MissionStatus = 'active' | 'completed' | 'failed'
export type NotificationType = 'success' | 'error' | 'warning' | 'info'
export type UITab = 'dashboard' | 'districts' | 'missions' | 'teams' | 'analytics' | 'settings'

// FiveM Specific Types
declare global {
  interface Window {
    GetParentResourceName: () => string
    invokeNative: (hash: string, ...args: any[]) => any
  }
} 