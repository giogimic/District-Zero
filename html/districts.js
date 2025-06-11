// District Control UI
let currentDistricts = [];
let selectedDistrict = null;

// DOM Elements
const districtsContainer = document.getElementById('districts-container');
const districtsList = document.getElementById('districts-list');
const districtDetails = document.getElementById('district-details');
const districtName = document.getElementById('district-name');
const districtDescription = document.getElementById('district-description');
const districtControl = document.getElementById('district-control');
const districtPlayers = document.getElementById('district-players');
const districtEvents = document.getElementById('district-events');
const startEventButton = document.getElementById('start-event');
const closeDistrictsButton = document.getElementById('close-districts');

// Event Listeners
districtsList.addEventListener('click', (event) => {
    const districtItem = event.target.closest('.district-item');
    if (districtItem) {
        const districtId = districtItem.dataset.districtId;
        selectDistrict(districtId);
    }
});

startEventButton.addEventListener('click', () => {
    if (selectedDistrict) {
        showEventSelection();
    }
});

closeDistrictsButton.addEventListener('click', () => {
    window.UI.sendNUICallback('closeDistricts');
    hideDistricts();
});

// Functions
function selectDistrict(districtId) {
    selectedDistrict = currentDistricts.find(district => district.id === districtId);
    if (selectedDistrict) {
        updateDistrictDetails(selectedDistrict);
        districtsList.querySelectorAll('.district-item').forEach(item => {
            item.classList.toggle('selected', item.dataset.districtId === districtId);
        });
    }
}

function updateDistrictDetails(district) {
    districtName.textContent = district.name;
    districtDescription.textContent = district.description;
    
    // Update control status
    districtControl.innerHTML = `
        <div class="control-status">
            <span class="faction-${district.controllingFaction}">${district.controllingFaction}</span>
            <div class="control-progress">
                <div class="progress" style="width: ${district.controlPercentage}%"></div>
            </div>
        </div>
    `;
    
    // Update players list
    districtPlayers.innerHTML = '';
    if (district.players && district.players.length > 0) {
        district.players.forEach(player => {
            const playerElement = document.createElement('div');
            playerElement.className = 'player';
            playerElement.innerHTML = `
                <span class="player-name">${player.name}</span>
                <span class="faction-${player.faction}">${player.faction}</span>
            `;
            districtPlayers.appendChild(playerElement);
        });
    } else {
        districtPlayers.innerHTML = '<div class="no-players">No players in district</div>';
    }
    
    // Update events list
    districtEvents.innerHTML = '';
    if (district.activeEvents && district.activeEvents.length > 0) {
        district.activeEvents.forEach(event => {
            const eventElement = document.createElement('div');
            eventElement.className = 'event';
            eventElement.innerHTML = `
                <div class="event-header">
                    <span class="event-name">${event.name}</span>
                    <span class="event-time">${window.UI.formatTime(event.timeLeft)}</span>
                </div>
                <div class="event-description">${event.description}</div>
                <div class="event-participants">
                    ${event.participants.length} participants
                </div>
            `;
            districtEvents.appendChild(eventElement);
        });
    } else {
        districtEvents.innerHTML = '<div class="no-events">No active events</div>';
    }
    
    // Update button state
    startEventButton.disabled = !canStartEvent(district);
}

function canStartEvent(district) {
    // Check if player's faction can start events in this district
    return district.controllingFaction === 'player_faction' || district.controllingFaction === 'neutral';
}

function showEventSelection() {
    const eventTypes = [
        { id: 'raid', name: 'Raid', description: 'Attack enemy territory' },
        { id: 'emergency', name: 'Emergency', description: 'Respond to district crisis' },
        { id: 'turf_war', name: 'Turf War', description: 'Fight for district control' },
        { id: 'gang_attack', name: 'Gang Attack', description: 'Defend against gang attack' },
        { id: 'patrol', name: 'Patrol', description: 'Maintain district security' }
    ];
    
    const eventSelection = document.createElement('div');
    eventSelection.className = 'event-selection';
    eventSelection.innerHTML = `
        <div class="event-selection-header">
            <h3>Select Event Type</h3>
            <button class="close-events">×</button>
        </div>
        <div class="event-types">
            ${eventTypes.map(event => `
                <div class="event-type" data-event-id="${event.id}">
                    <h4>${event.name}</h4>
                    <p>${event.description}</p>
                </div>
            `).join('')}
        </div>
    `;
    
    districtsContainer.appendChild(eventSelection);
    
    // Add event listeners
    eventSelection.querySelector('.close-events').addEventListener('click', () => {
        eventSelection.remove();
    });
    
    eventSelection.querySelectorAll('.event-type').forEach(element => {
        element.addEventListener('click', () => {
            const eventId = element.dataset.eventId;
            startEvent(eventId);
            eventSelection.remove();
        });
    });
}

function startEvent(eventId) {
    if (selectedDistrict) {
        window.UI.sendNUICallback('startEvent', {
            districtId: selectedDistrict.id,
            eventId: eventId
        });
    }
}

function updateDistrictsList(districts) {
    currentDistricts = districts;
    districtsList.innerHTML = '';
    
    districts.forEach(district => {
        const districtItem = document.createElement('div');
        districtItem.className = `district-item faction-${district.controllingFaction}`;
        districtItem.dataset.districtId = district.id;
        
        districtItem.innerHTML = `
            <div class="district-info">
                <h3>${district.name}</h3>
                <p>${district.shortDescription}</p>
            </div>
            <div class="district-status">
                <span class="faction-${district.controllingFaction}">${district.controllingFaction}</span>
                ${district.activeEvents ? 
                    `<span class="active-events">${district.activeEvents.length} events</span>` :
                    ''
                }
            </div>
        `;
        
        districtsList.appendChild(districtItem);
    });
}

// Handle district updates
districtsContainer.addEventListener('districts:update', (event) => {
    const { districts } = event.detail;
    updateDistrictsList(districts);
    
    if (selectedDistrict) {
        const updatedDistrict = districts.find(d => d.id === selectedDistrict.id);
        if (updatedDistrict) {
            updateDistrictDetails(updatedDistrict);
        }
    }
});

// Handle event updates
districtsContainer.addEventListener('district:event', (event) => {
    const { districtId, event } = event.detail;
    if (selectedDistrict && selectedDistrict.id === districtId) {
        updateDistrictDetails(selectedDistrict);
    }
});

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    // Request initial districts data
    window.UI.sendNUICallback('getDistricts');
}); 