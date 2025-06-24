// NUI Communication utilities for FiveM

export interface NUIEvent {
  type: string
  data?: any
  callbackId?: string
}

export interface NUICallback {
  success: boolean
  data?: any
  error?: string
}

export interface NUIResponse {
  success: boolean
  data?: any
  error?: string
}

// Send message to client script
export const sendNUIMessage = (event: NUIEvent): void => {
  if (typeof window !== 'undefined' && window.invokeNative) {
    window.invokeNative('SEND_NUI_MESSAGE', JSON.stringify(event))
  } else {
    // Fallback for development
    console.log('NUI Message:', event)
  }
}

// Send message and wait for callback
export const sendNUICallback = async (
  event: NUIEvent,
  timeout: number = 5000
): Promise<NUIResponse> => {
  return new Promise((resolve) => {
    const callbackId = Math.random().toString(36).substr(2, 9)
    const timeoutId = setTimeout(() => {
      resolve({
        success: false,
        error: 'NUI callback timeout',
      })
    }, timeout)

    // Listen for response
    const handleResponse = (event: MessageEvent) => {
      if (event.data?.callbackId === callbackId) {
        clearTimeout(timeoutId)
        window.removeEventListener('message', handleResponse)
        resolve(event.data)
      }
    }

    window.addEventListener('message', handleResponse)

    // Send message with callback ID
    sendNUIMessage({
      ...event,
      callbackId,
    })
  })
}

// Listen for messages from client script
export const onNUIMessage = (callback: (event: NUIEvent) => void): (() => void) => {
  const handleMessage = (event: MessageEvent) => {
    if (event.data && typeof event.data === 'object') {
      callback(event.data)
    }
  }

  window.addEventListener('message', handleMessage)

  // Return cleanup function
  return () => {
    window.removeEventListener('message', handleMessage)
  }
}

// Close NUI
export const closeNUI = (): void => {
  sendNUIMessage({ type: 'closeUI' })
}

// Focus NUI
export const focusNUI = (hasFocus: boolean = true, hasCursor: boolean = true): void => {
  sendNUIMessage({
    type: 'setNuiFocus',
    data: { hasFocus, hasCursor },
  })
}

// Common NUI actions
export const nuiActions = {
  // Team actions
  selectTeam: (team: 'pvp' | 'pve') =>
    sendNUICallback({
      type: 'selectTeam',
      data: { team },
    }),

  // Mission actions
  acceptMission: (missionId: string) =>
    sendNUICallback({
      type: 'acceptMission',
      data: { missionId },
    }),

  capturePoint: (missionId: string, objectiveId: number) =>
    sendNUICallback({
      type: 'capturePoint',
      data: { missionId, objectiveId },
    }),

  // District actions
  requestDistrictUpdate: (districtId: string) =>
    sendNUICallback({
      type: 'requestDistrictUpdate',
      data: { districtId },
    }),

  // Team actions
  requestTeamUpdate: () =>
    sendNUICallback({
      type: 'requestTeamUpdate',
      data: {},
    }),

  // UI actions
  closeUI: () => sendNUICallback({ type: 'closeUI' }),
  getUIData: () => sendNUICallback({ type: 'getUIData' }),
}

// Development helpers
export const isDevelopment = (): boolean => {
  return import.meta.env?.DEV === true
}

// Mock data for development
export const mockData = {
  districts: [
    {
      id: 'downtown',
      name: 'Downtown',
      description: 'The heart of the city',
      influence_pvp: 65,
      influence_pve: 35,
      last_updated: new Date().toISOString(),
      zones: [
        {
          name: 'Central Plaza',
          coords: [0, 0, 0] as [number, number, number],
          radius: 100,
          isSafeZone: false,
        },
      ],
      controlPoints: [
        {
          id: 1,
          district_id: 'downtown',
          name: 'City Hall',
          coords: [10, 10, 0] as [number, number, number],
          radius: 25,
          influence: 25,
          current_team: 'pvp' as const,
          last_captured: new Date().toISOString(),
        },
      ],
    },
  ],
  missions: [
    {
      id: 'mission_1',
      title: 'Secure Downtown',
      description: 'Capture control points in downtown district',
      type: 'pvp' as const,
      district_id: 'downtown',
      reward: 5000,
      objectives: [
        {
          id: 1,
          type: 'capture' as const,
          description: 'Capture City Hall control point',
          completed: false,
          progress: 0,
          max_progress: 100,
        },
      ],
      active: true,
    },
  ],
  teams: [
    {
      id: 'pvp' as const,
      name: 'PvP Team',
      description: 'Player vs Player combat team',
      color: '#ff4444',
      members: 12,
      influence: 65,
    },
    {
      id: 'pve' as const,
      name: 'PvE Team',
      description: 'Player vs Environment team',
      color: '#4444ff',
      members: 8,
      influence: 35,
    },
  ],
} 