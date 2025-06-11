// State management
let state = {
  visible: false,
  activeMission: null,
  availableMissions: []
};

// DOM Elements
const app = document.getElementById('app');
const missionList = document.getElementById('missionList');
const missionInfo = document.getElementById('missionInfo');
const closeBtn = document.getElementById('closeBtn');
const acceptBtn = document.getElementById('acceptBtn');
const declineBtn = document.getElementById('declineBtn');

// Event Listeners
closeBtn.addEventListener('click', () => {
  hideUI();
  fetch('https://district-zero/close', {
    method: 'POST',
    body: JSON.stringify({})
  });
});

acceptBtn.addEventListener('click', () => {
  if (state.activeMission) {
    fetch('https://district-zero/acceptMission', {
      method: 'POST',
      body: JSON.stringify({ missionId: state.activeMission.id })
    });
    hideUI();
  }
});

declineBtn.addEventListener('click', () => {
  if (state.activeMission) {
    fetch('https://district-zero/declineMission', {
      method: 'POST',
      body: JSON.stringify({ missionId: state.activeMission.id })
    });
    showMissionList();
  }
});

// Message Handler
window.addEventListener('message', (event) => {
  const { type, data } = event.data;
  
  switch (type) {
    case 'show':
      state.availableMissions = data.missions;
      showUI();
      renderMissionList();
      break;
      
    case 'hide':
      hideUI();
      break;
      
    case 'updateMission':
      state.activeMission = data.mission;
      renderMissionInfo();
      break;
  }
});

// UI Functions
function showUI() {
  state.visible = true;
  app.classList.remove('hidden');
}

function hideUI() {
  state.visible = false;
  app.classList.add('hidden');
  state.activeMission = null;
}

function showMissionList() {
  missionList.classList.remove('hidden');
  missionInfo.classList.add('hidden');
}

function showMissionInfo() {
  missionList.classList.add('hidden');
  missionInfo.classList.remove('hidden');
}

// Render Functions
function renderMissionList() {
  missionList.innerHTML = state.availableMissions.map(mission => `
    <div class="mission-card" data-mission-id="${mission.id}">
      <h3>${mission.title}</h3>
      <p>${mission.description}</p>
      <div class="mission-meta">
        <span class="difficulty">${mission.difficulty}</span>
        <span class="reward">${mission.reward}</span>
      </div>
    </div>
  `).join('');
  
  // Add click handlers to mission cards
  document.querySelectorAll('.mission-card').forEach(card => {
    card.addEventListener('click', () => {
      const missionId = card.dataset.missionId;
      const mission = state.availableMissions.find(m => m.id === missionId);
      if (mission) {
        state.activeMission = mission;
        renderMissionInfo();
        showMissionInfo();
      }
    });
  });
}

function renderMissionInfo() {
  if (!state.activeMission) return;
  
  const { title, description, objectives } = state.activeMission;
  
  document.getElementById('missionTitle').textContent = title;
  document.getElementById('missionDescription').textContent = description;
  
  document.getElementById('missionObjectives').innerHTML = objectives.map(obj => `
    <div class="objective ${obj.completed ? 'completed' : ''}">
      <span class="objective-icon">${obj.completed ? '✓' : '○'}</span>
      <span class="objective-text">${obj.description}</span>
    </div>
  `).join('');
} 