import { create } from 'zustand'
import { devtools, subscribeWithSelector } from 'zustand/middleware'
import type {
  UIState,
  District,
  Mission,
  Team,
  PlayerStats,
  TeamBalance,
  Notification,
  UITab,
  TeamType
} from '@/types'

interface DistrictZeroStore extends UIState {
  // Data
  districts: District[]
  missions: Mission[]
  teams: Team[]
  playerStats: PlayerStats | null
  teamBalance: TeamBalance | null
  
  // Actions
  setOpen: (isOpen: boolean) => void
  setCurrentTab: (tab: UITab) => void
  setCurrentDistrict: (district: District | null) => void
  setCurrentTeam: (team: TeamType | null) => void
  setCurrentMission: (mission: Mission | null) => void
  setLoading: (loading: boolean) => void
  setError: (error: string | null) => void
  
  // Data Actions
  setDistricts: (districts: District[]) => void
  setMissions: (missions: Mission[]) => void
  setTeams: (teams: Team[]) => void
  setPlayerStats: (stats: PlayerStats | null) => void
  setTeamBalance: (balance: TeamBalance | null) => void
  
  // District Actions
  updateDistrict: (districtId: string, updates: Partial<District>) => void
  updateDistrictInfluence: (districtId: string, team: TeamType, influence: number) => void
  
  // Mission Actions
  updateMission: (missionId: string, updates: Partial<Mission>) => void
  updateMissionObjective: (missionId: string, objectiveId: number, completed: boolean) => void
  
  // Team Actions
  updateTeam: (teamId: TeamType, updates: Partial<Team>) => void
  
  // Notification Actions
  addNotification: (notification: Omit<Notification, 'id' | 'timestamp'>) => void
  removeNotification: (id: string) => void
  clearNotifications: () => void
  
  // Utility Actions
  reset: () => void
}

const initialState = {
  isOpen: false,
  currentTab: 'dashboard' as UITab,
  currentDistrict: null as District | null,
  currentTeam: null as TeamType | null,
  currentMission: null as Mission | null,
  notifications: [] as Notification[],
  loading: false,
  error: null as string | null,
  districts: [] as District[],
  missions: [] as Mission[],
  teams: [] as Team[],
  playerStats: null as PlayerStats | null,
  teamBalance: null as TeamBalance | null,
}

export const useDistrictZeroStore = create<DistrictZeroStore>()(
  devtools(
    subscribeWithSelector((set) => ({
      ...initialState,

      // UI Actions
      setOpen: (isOpen) => set({ isOpen }),
      setCurrentTab: (currentTab) => set({ currentTab }),
      setCurrentDistrict: (currentDistrict) => set({ currentDistrict }),
      setCurrentTeam: (currentTeam) => set({ currentTeam }),
      setCurrentMission: (currentMission) => set({ currentMission }),
      setLoading: (loading) => set({ loading }),
      setError: (error) => set({ error }),

      // Data Actions
      setDistricts: (districts) => set({ districts }),
      setMissions: (missions) => set({ missions }),
      setTeams: (teams) => set({ teams }),
      setPlayerStats: (playerStats) => set({ playerStats }),
      setTeamBalance: (teamBalance) => set({ teamBalance }),

      // District Actions
      updateDistrict: (districtId, updates) =>
        set((state) => ({
          districts: state.districts.map((district) =>
            district.id === districtId ? { ...district, ...updates } : district
          ),
          currentDistrict:
            state.currentDistrict?.id === districtId
              ? { ...state.currentDistrict, ...updates }
              : state.currentDistrict,
        })),

      updateDistrictInfluence: (districtId, team, influence) =>
        set((state) => ({
          districts: state.districts.map((district) =>
            district.id === districtId
              ? {
                  ...district,
                  influence_pvp: team === 'pvp' ? influence : district.influence_pvp,
                  influence_pve: team === 'pve' ? influence : district.influence_pve,
                }
              : district
          ),
          currentDistrict:
            state.currentDistrict?.id === districtId
              ? {
                  ...state.currentDistrict,
                  influence_pvp: team === 'pvp' ? influence : state.currentDistrict.influence_pvp,
                  influence_pve: team === 'pve' ? influence : state.currentDistrict.influence_pve,
                }
              : state.currentDistrict,
        })),

      // Mission Actions
      updateMission: (missionId, updates) =>
        set((state) => ({
          missions: state.missions.map((mission) =>
            mission.id === missionId ? { ...mission, ...updates } : mission
          ),
          currentMission:
            state.currentMission?.id === missionId
              ? { ...state.currentMission, ...updates }
              : state.currentMission,
        })),

      updateMissionObjective: (missionId, objectiveId, completed) =>
        set((state) => ({
          missions: state.missions.map((mission) =>
            mission.id === missionId
              ? {
                  ...mission,
                  objectives: mission.objectives.map((objective) =>
                    objective.id === objectiveId
                      ? { ...objective, completed, progress: completed ? objective.max_progress : 0 }
                      : objective
                  ),
                }
              : mission
          ),
          currentMission:
            state.currentMission?.id === missionId
              ? {
                  ...state.currentMission,
                  objectives: state.currentMission.objectives.map((objective) =>
                    objective.id === objectiveId
                      ? { ...objective, completed, progress: completed ? objective.max_progress : 0 }
                      : objective
                  ),
                }
              : state.currentMission,
        })),

      // Team Actions
      updateTeam: (teamId, updates) =>
        set((state) => ({
          teams: state.teams.map((team) =>
            team.id === teamId ? { ...team, ...updates } : team
          ),
        })),

      // Notification Actions
      addNotification: (notification) =>
        set((state) => ({
          notifications: [
            ...state.notifications,
            {
              ...notification,
              id: Math.random().toString(36).substr(2, 9),
              timestamp: Date.now(),
            },
          ],
        })),

      removeNotification: (id) =>
        set((state) => ({
          notifications: state.notifications.filter((n) => n.id !== id),
        })),

      clearNotifications: () => set({ notifications: [] }),

      // Utility Actions
      reset: () => set(initialState),
    })),
    {
      name: 'district-zero-store',
    }
  )
)

// Selectors for better performance
export const useDistricts = () => useDistrictZeroStore((state) => state.districts)
export const useMissions = () => useDistrictZeroStore((state) => state.missions)
export const useTeams = () => useDistrictZeroStore((state) => state.teams)
export const useCurrentDistrict = () => useDistrictZeroStore((state) => state.currentDistrict)
export const useCurrentTeam = () => useDistrictZeroStore((state) => state.currentTeam)
export const useCurrentMission = () => useDistrictZeroStore((state) => state.currentMission)
export const useCurrentTab = () => useDistrictZeroStore((state) => state.currentTab)
export const useNotifications = () => useDistrictZeroStore((state) => state.notifications)
export const useLoading = () => useDistrictZeroStore((state) => state.loading)
export const useError = () => useDistrictZeroStore((state) => state.error)

// Computed selectors
export const useAvailableMissions = () =>
  useDistrictZeroStore((state) => {
    if (!state.currentDistrict || !state.currentTeam) return []
    return state.missions.filter(
      (mission) =>
        mission.district_id === state.currentDistrict!.id &&
        mission.type === state.currentTeam &&
        mission.active
    )
  })

export const useDistrictInfluence = (districtId: string) =>
  useDistrictZeroStore((state) => {
    const district = state.districts.find((d) => d.id === districtId)
    if (!district) return { pvp: 0, pve: 0 }
    return {
      pvp: district.influence_pvp,
      pve: district.influence_pve,
    }
  })

export const useTeamStats = (teamId: TeamType) =>
  useDistrictZeroStore((state) => {
    const team = state.teams.find((t) => t.id === teamId)
    if (!team) return null
    return team
  }) 