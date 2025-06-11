<template>
  <div id="app" v-show="visible">
    <div class="container">
      <div class="header">
        <h1>District Zero</h1>
        <button class="close-btn" @click="closeUI">×</button>
      </div>
      <div class="content">
        <div class="tabs">
          <button 
            v-for="tab in tabs" 
            :key="tab.id"
            :class="{ active: currentTab === tab.id }"
            @click="currentTab = tab.id"
          >
            {{ tab.name }}
          </button>
        </div>
        <div class="tab-content">
          <div v-if="currentTab === 'missions'">
            <h2>Available Missions</h2>
            <div class="mission-list">
              <div v-for="mission in missions" :key="mission.id" class="mission-card">
                <h3>{{ mission.title }}</h3>
                <p>{{ mission.description }}</p>
                <div class="mission-details">
                  <span>Difficulty: {{ mission.difficulty }}</span>
                  <span>Reward: ${{ mission.reward }}</span>
                </div>
                <button @click="acceptMission(mission.id)">Accept Mission</button>
              </div>
            </div>
          </div>
          <div v-if="currentTab === 'districts'">
            <h2>Districts</h2>
            <div class="district-list">
              <div v-for="district in districts" :key="district.id" class="district-card">
                <h3>{{ district.name }}</h3>
                <p>{{ district.description }}</p>
                <div class="district-details">
                  <span>Control: {{ district.owner }}</span>
                  <span>Influence: {{ district.influence }}%</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'App',
  data() {
    return {
      visible: false,
      currentTab: 'missions',
      tabs: [
        { id: 'missions', name: 'Missions' },
        { id: 'districts', name: 'Districts' }
      ],
      missions: [],
      districts: []
    }
  },
  methods: {
    closeUI() {
      this.visible = false
      fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
      })
    },
    acceptMission(missionId) {
      fetch(`https://${GetParentResourceName()}/acceptMission`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ missionId })
      })
    }
  },
  mounted() {
    window.addEventListener('message', (event) => {
      const data = event.data
      
      if (data.type === 'showUI') {
        this.visible = true
        this.missions = data.missions || []
        this.districts = data.districts || []
      } else if (data.type === 'hideUI') {
        this.visible = false
      }
    })

    // Close on Escape key
    window.addEventListener('keyup', (event) => {
      if (event.key === 'Escape') {
        this.closeUI()
      }
    })
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 80%;
  max-width: 1200px;
  background: rgba(0, 0, 0, 0.9);
  border-radius: 8px;
  padding: 20px;
  color: white;
}

.container {
  width: 100%;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.close-btn {
  background: none;
  border: none;
  color: white;
  font-size: 24px;
  cursor: pointer;
  padding: 5px 10px;
}

.tabs {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
}

.tabs button {
  background: rgba(255, 255, 255, 0.1);
  border: none;
  color: white;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
}

.tabs button.active {
  background: rgba(255, 255, 255, 0.2);
}

.mission-list, .district-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.mission-card, .district-card {
  background: rgba(255, 255, 255, 0.1);
  padding: 15px;
  border-radius: 4px;
}

.mission-details, .district-details {
  display: flex;
  justify-content: space-between;
  margin: 10px 0;
}

button {
  background: #4CAF50;
  border: none;
  color: white;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
  width: 100%;
}

button:hover {
  background: #45a049;
}
</style> 