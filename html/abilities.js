let abilities = [];
let cooldowns = {};

// Faction Abilities UI
let currentAbilities = [];
let selectedAbility = null;

// DOM Elements
const abilitiesContainer = document.getElementById('abilities-container');
const abilitiesList = document.getElementById('abilities-list');
const abilityDetails = document.getElementById('ability-details');
const abilityName = document.getElementById('ability-name');
const abilityDescription = document.getElementById('ability-description');
const abilityCooldown = document.getElementById('ability-cooldown');
const abilityCost = document.getElementById('ability-cost');
const abilityRequirements = document.getElementById('ability-requirements');
const useAbilityButton = document.getElementById('use-ability');

// Initialize the UI
document.addEventListener('DOMContentLoaded', () => {
    window.addEventListener('message', handleMessage);
    // Request initial abilities data
    window.UI.sendNUICallback('getAbilities');
});

// Handle messages from the game client
function handleMessage(event) {
    const data = event.data;

    switch (data.type) {
        case 'show':
            showUI(data.faction, data.abilities);
            break;
        case 'hide':
            hideUI();
            break;
        case 'updateCooldown':
            updateCooldown(data.abilityId, data.remainingTime, data.totalTime);
            break;
        case 'updateFaction':
            updateFactionInfo(data.faction, data.rank);
            break;
    }
}

// Show the UI with faction abilities
function showUI(faction, factionAbilities) {
    abilities = factionAbilities;
    updateFactionInfo(faction.name, faction.rank);
    populateAbilities();
    document.getElementById('abilities-ui').classList.remove('hidden');
}

// Hide the UI
function hideUI() {
    document.getElementById('abilities-ui').classList.add('hidden');
}

// Update faction information
function updateFactionInfo(name, rank) {
    document.getElementById('faction-name').textContent = name;
    document.getElementById('faction-rank').textContent = `Rank ${rank}`;
}

// Populate abilities list
function populateAbilities() {
    const abilitiesList = document.querySelector('.abilities-list');
    abilitiesList.innerHTML = '';

    abilities.forEach(ability => {
        const abilityElement = createAbilityElement(ability);
        abilitiesList.appendChild(abilityElement);
    });
}

// Create an ability element
function createAbilityElement(ability) {
    const div = document.createElement('div');
    div.className = `ability-item ${ability.locked ? 'locked' : ''}`;
    div.dataset.abilityId = ability.id;

    div.innerHTML = `
        <div class="ability-header">
            <span class="ability-name">${ability.name}</span>
            <span class="ability-rank">Rank ${ability.requiredRank}</span>
        </div>
        <div class="ability-description">${ability.description}</div>
        <div class="ability-cooldown">
            <span>Cooldown:</span>
            <div class="cooldown-bar">
                <div class="cooldown-progress" style="width: 0%"></div>
            </div>
            <span class="cooldown-text">0s</span>
        </div>
    `;

    return div;
}

// Update ability cooldown
function updateCooldown(abilityId, remainingTime, totalTime) {
    const abilityElement = document.querySelector(`[data-ability-id="${abilityId}"]`);
    if (!abilityElement) return;

    const progressBar = abilityElement.querySelector('.cooldown-progress');
    const cooldownText = abilityElement.querySelector('.cooldown-text');
    
    const progress = (remainingTime / totalTime) * 100;
    progressBar.style.width = `${progress}%`;
    cooldownText.textContent = `${Math.ceil(remainingTime / 1000)}s`;

    if (remainingTime <= 0) {
        abilityElement.classList.add('ready');
    } else {
        abilityElement.classList.remove('ready');
    }
}

// Handle key presses
document.addEventListener('keydown', (event) => {
    if (document.getElementById('abilities-ui').classList.contains('hidden')) return;

    switch (event.key) {
        case 'F1':
            triggerAbility('backup');
            break;
        case 'F2':
            triggerAbility('tracking');
            break;
        case 'F3':
            triggerAbility('jammer');
            break;
    }
});

// Trigger ability
function triggerAbility(abilityId) {
    fetch(`https://${GetParentResourceName()}/triggerAbility`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            abilityId: abilityId
        })
    });
}

// Event Listeners
abilitiesList.addEventListener('click', (event) => {
    const abilityItem = event.target.closest('.ability-item');
    if (abilityItem) {
        const abilityId = abilityItem.dataset.abilityId;
        selectAbility(abilityId);
    }
});

useAbilityButton.addEventListener('click', () => {
    if (selectedAbility) {
        useAbility(selectedAbility.id);
    }
});

// Functions
function selectAbility(abilityId) {
    selectedAbility = currentAbilities.find(ability => ability.id === abilityId);
    if (selectedAbility) {
        updateAbilityDetails(selectedAbility);
        abilitiesList.querySelectorAll('.ability-item').forEach(item => {
            item.classList.toggle('selected', item.dataset.abilityId === abilityId);
        });
    }
}

function updateAbilityDetails(ability) {
    abilityName.textContent = ability.name;
    abilityDescription.textContent = ability.description;
    abilityCooldown.textContent = `${ability.cooldown}s`;
    abilityCost.textContent = `${ability.cost} points`;
    
    // Update requirements
    abilityRequirements.innerHTML = '';
    if (ability.requirements) {
        Object.entries(ability.requirements).forEach(([key, value]) => {
            const requirement = document.createElement('div');
            requirement.className = 'requirement';
            requirement.innerHTML = `
                <span class="requirement-name">${key}:</span>
                <span class="requirement-value">${value}</span>
            `;
            abilityRequirements.appendChild(requirement);
        });
    }
    
    // Update button state
    useAbilityButton.disabled = !ability.available;
    useAbilityButton.textContent = ability.available ? 'Use Ability' : 'Unavailable';
}

function useAbility(abilityId) {
    window.UI.sendNUICallback('useAbility', { abilityId });
}

// Update abilities list
function updateAbilitiesList(abilities) {
    currentAbilities = abilities;
    abilitiesList.innerHTML = '';
    
    abilities.forEach(ability => {
        const abilityItem = document.createElement('div');
        abilityItem.className = `ability-item ${ability.available ? 'available' : 'unavailable'}`;
        abilityItem.dataset.abilityId = ability.id;
        
        abilityItem.innerHTML = `
            <div class="ability-icon">
                <img src="img/abilities/${ability.icon}" alt="${ability.name}">
            </div>
            <div class="ability-info">
                <h3>${ability.name}</h3>
                <p>${ability.shortDescription}</p>
            </div>
            <div class="ability-status">
                ${ability.available ? 
                    `<span class="cooldown">${ability.currentCooldown}s</span>` :
                    '<span class="locked">Locked</span>'
                }
            </div>
        `;
        
        abilitiesList.appendChild(abilityItem);
    });
}

// Handle ability updates
abilitiesContainer.addEventListener('abilities:update', (event) => {
    const { abilities } = event.detail;
    updateAbilitiesList(abilities);
    
    if (selectedAbility) {
        const updatedAbility = abilities.find(a => a.id === selectedAbility.id);
        if (updatedAbility) {
            updateAbilityDetails(updatedAbility);
        }
    }
});

// Handle ability cooldown updates
abilitiesContainer.addEventListener('ability:cooldown', (event) => {
    const { abilityId, cooldown } = event.detail;
    const abilityItem = abilitiesList.querySelector(`[data-ability-id="${abilityId}"]`);
    if (abilityItem) {
        const cooldownElement = abilityItem.querySelector('.cooldown');
        if (cooldownElement) {
            cooldownElement.textContent = `${cooldown}s`;
        }
    }
    
    if (selectedAbility && selectedAbility.id === abilityId) {
        abilityCooldown.textContent = `${cooldown}s`;
    }
}); 