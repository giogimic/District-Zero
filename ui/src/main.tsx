import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'
import './styles/index.css'

// Initialize NUI communication
import { onNUIMessage } from './utils/nui'
import { useDistrictZeroStore } from './store'

// Set up NUI message listener
const unsubscribe = onNUIMessage((event) => {
  const store = useDistrictZeroStore.getState()
  
  switch (event.type) {
    case 'showUI':
      store.setOpen(true)
      if (event.data?.showTeamSelect) {
        // Show team selection modal
        store.setCurrentDistrict(event.data.district)
        // The team selection modal will be handled by the App component
      }
      break
      
    case 'hideUI':
      store.setOpen(false)
      break
      
    case 'updateUI':
      if (event.data?.districts) {
        store.setDistricts(event.data.districts)
      }
      if (event.data?.missions) {
        store.setMissions(event.data.missions)
      }
      if (event.data?.teams) {
        store.setTeams(event.data.teams)
      }
      if (event.data?.currentDistrict) {
        store.setCurrentDistrict(event.data.currentDistrict)
      }
      if (event.data?.currentTeam) {
        store.setCurrentTeam(event.data.currentTeam)
      }
      if (event.data?.playerStats) {
        store.setPlayerStats(event.data.playerStats)
      }
      if (event.data?.teamBalance) {
        store.setTeamBalance(event.data.teamBalance)
      }
      break
      
    case 'team:selected':
      store.setCurrentTeam(event.data?.team)
      store.addNotification({
        type: 'success',
        message: `Team selected: ${event.data?.team === 'pvp' ? 'PvP' : 'PvE'}`,
      })
      break
      
    case 'showNotification':
      store.addNotification({
        type: event.data?.type || 'info',
        message: event.data?.message || 'Notification',
        title: event.data?.title,
        duration: event.data?.duration || 5000,
      })
      break
      
    case 'mission:started':
      if (event.data?.mission) {
        store.setCurrentMission(event.data.mission)
        store.addNotification({
          type: 'success',
          message: `Mission started: ${event.data.mission.title}`,
        })
      }
      break
      
    case 'mission:completed':
      store.setCurrentMission(null)
      store.addNotification({
        type: 'success',
        message: `Mission completed! Reward: $${event.data?.reward?.toLocaleString() || 0}`,
      })
      break
      
    case 'mission:failed':
      store.setCurrentMission(null)
      store.addNotification({
        type: 'error',
        message: `Mission failed: ${event.data?.reason || 'Unknown error'}`,
      })
      break
      
    case 'mission:sync':
      if (event.data?.mission) {
        store.updateMission(event.data.mission.id, event.data.mission)
      }
      break
      
    case 'district:controlChanged':
      store.addNotification({
        type: 'info',
        message: `District control changed to ${event.data?.team?.toUpperCase() || 'Unknown'}`,
      })
      break
      
    case 'district:sync':
      if (event.data?.districts) {
        store.setDistricts(event.data.districts)
      }
      break
      
    case 'team:sync':
      if (event.data?.currentTeam) {
        store.setCurrentTeam(event.data.currentTeam)
      }
      if (event.data?.balance) {
        store.setTeamBalance(event.data.balance)
      }
      break
      
    case 'controlPoint:captureStarted':
      store.addNotification({
        type: 'info',
        message: 'Control point capture started!',
      })
      break
      
    case 'controlPoint:captured':
      store.addNotification({
        type: 'success',
        message: `Control point captured by ${event.data?.team?.toUpperCase() || 'Unknown'}!`,
      })
      break
      
    default:
      console.log('Unknown NUI event:', event)
  }
})

// Cleanup on unmount
window.addEventListener('beforeunload', () => {
  unsubscribe()
})

// Development mode setup
if (typeof import.meta !== 'undefined' && import.meta.env?.DEV) {
  console.log('District Zero UI running in development mode')
  
  // Load mock data for development
  import('./utils/nui').then(({ mockData }) => {
    const store = useDistrictZeroStore.getState()
    store.setDistricts(mockData.districts)
    store.setMissions(mockData.missions)
    store.setTeams(mockData.teams)
    store.setCurrentDistrict(mockData.districts[0])
    store.setOpen(true)
  })
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
) 