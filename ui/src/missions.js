// Mission UI
let currentMission = null;
let missionTimerInterval = null;

// DOM Elements
const missionContainer = document.getElementById('mission-container');
const missionTitle = document.getElementById('mission-title');
const missionDescription = document.getElementById('mission-description');
const missionTimerElement = document.getElementById('mission-timer');
const missionObjectives = document.getElementById('mission-objectives');
const missionRewards = document.getElementById('mission-rewards');
const missionProgress = document.getElementById('mission-progress');
const closeMissionButton = document.getElementById('close-mission');

// Event Listeners
closeMissionButton.addEventListener('click', () => {
    window.UI.sendNUICallback('closeMission');
    hideMission();
});

// Functions
function showMission(mission) {
    currentMission = mission;
    updateMissionUI(mission);
    missionContainer.classList.remove('hidden');
}

function hideMission() {
    missionContainer.classList.add('hidden');
    currentMission = null;
    if (missionTimerInterval) {
        clearInterval(missionTimerInterval);
        missionTimerInterval = null;
    }
}

function updateMissionUI(mission) {
    missionTitle.textContent = mission.title;
    missionDescription.textContent = mission.description;
    
    // Update objectives
    missionObjectives.innerHTML = '';
    mission.objectives.forEach((objective, index) => {
        const objectiveElement = document.createElement('div');
        objectiveElement.className = 'objective';
        objectiveElement.innerHTML = `
            <div class="objective-header">
                <span class="objective-name">${objective.name}</span>
                <span class="objective-progress">${objective.completed}/${objective.required}</span>
            </div>
            <div class="objective-progress-bar">
                <div class="progress" style="width: ${(objective.completed / objective.required) * 100}%"></div>
            </div>
        `;
        missionObjectives.appendChild(objectiveElement);
    });
    
    // Update rewards
    missionRewards.innerHTML = '';
    if (mission.rewards) {
        Object.entries(mission.rewards).forEach(([type, amount]) => {
            const rewardElement = document.createElement('div');
            rewardElement.className = 'reward';
            rewardElement.innerHTML = `
                <span class="reward-type">${type}:</span>
                <span class="reward-amount">${window.UI.formatNumber(amount)}</span>
            `;
            missionRewards.appendChild(rewardElement);
        });
    }
    
    // Update timer if mission has time limit
    if (mission.timeLimit) {
        startMissionTimer(mission.timeLimit);
    } else {
        missionTimerElement.textContent = 'No time limit';
    }
    
    // Update overall progress
    const progress = calculateMissionProgress(mission);
    missionProgress.style.width = `${progress}%`;
}

function startMissionTimer(duration) {
    if (missionTimerInterval) {
        clearInterval(missionTimerInterval);
    }
    
    let timeLeft = duration;
    updateTimerDisplay(timeLeft);
    
    missionTimerInterval = setInterval(() => {
        timeLeft--;
        updateTimerDisplay(timeLeft);
        
        if (timeLeft <= 0) {
            clearInterval(missionTimerInterval);
            window.UI.sendNUICallback('missionFailed', { reason: 'timeout' });
            hideMission();
        }
    }, 1000);
}

function updateTimerDisplay(seconds) {
    missionTimerElement.textContent = window.UI.formatTime(seconds);
}

function updateObjective(index, completed) {
    if (!currentMission) return;
    
    const objective = currentMission.objectives[index];
    if (objective) {
        objective.completed = completed;
        updateMissionUI(currentMission);
    }
}

function calculateMissionProgress(mission) {
    if (!mission.objectives.length) return 0;
    
    const totalProgress = mission.objectives.reduce((sum, objective) => {
        return sum + (objective.completed / objective.required);
    }, 0);
    
    return (totalProgress / mission.objectives.length) * 100;
}

// Handle mission updates
missionContainer.addEventListener('mission:update', (event) => {
    const { mission } = event.detail;
    if (mission) {
        updateMissionUI(mission);
    }
});

// Handle objective updates
missionContainer.addEventListener('objective:update', (event) => {
    const { index, completed } = event.detail;
    updateObjective(index, completed);
});

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    // Request initial mission data if any
    window.UI.sendNUICallback('getCurrentMission');
}); 