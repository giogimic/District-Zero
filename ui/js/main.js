// Main UI Controller
class DistrictZeroUI {
    constructor() {
        this.app = document.getElementById('app');
        this.missionUI = document.getElementById('mission-ui');
        this.districtUI = document.getElementById('district-ui');
        this.teamUI = document.getElementById('team-ui');
        this.notifications = document.getElementById('notifications');
        
        this.currentTeam = null;
        this.currentMission = null;
        this.currentDistrict = null;
        
        this.init();
    }
    
    init() {
        // Listen for messages from the game
        window.addEventListener('message', this.handleMessage.bind(this));
        
        // Listen for key presses
        window.addEventListener('keyup', this.handleKeyPress.bind(this));
        
        // Initialize team selection
        this.initTeamSelection();
    }
    
    handleMessage(event) {
        const data = event.data;
        
        switch (data.type) {
            case 'showUI':
                this.showUI(data);
                break;
            case 'hideUI':
                this.hideUI();
                break;
            case 'updateUI':
                this.updateUI(data);
                break;
            case 'showNotification':
                this.showNotification(data.message, data.type);
                break;
        }
    }
    
    handleKeyPress(event) {
        if (event.key === 'Escape') {
            this.hideUI();
        }
    }
    
    showUI(data) {
        this.app.classList.remove('hidden');
        
        if (data.showTeamSelect) {
            this.showTeamSelection();
        } else {
            this.updateUI(data);
        }
    }
    
    hideUI() {
        this.app.classList.add('hidden');
        this.missionUI.classList.add('hidden');
        this.districtUI.classList.add('hidden');
        this.teamUI.classList.add('hidden');
        
        // Notify the game
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
    }
    
    updateUI(data) {
        if (data.currentDistrict) {
            this.currentDistrict = data.currentDistrict;
            this.showDistricts(data.districts);
            this.showMissions(data.missions);
        } else {
            this.hideUI();
        }
    }
    
    initTeamSelection() {
        const teamButtons = document.querySelectorAll('.team-btn');
        teamButtons.forEach(btn => {
            btn.addEventListener('click', () => {
                const team = btn.dataset.team;
                this.selectTeam(team);
            });
        });
    }
    
    selectTeam(team) {
        this.currentTeam = team;
        this.teamUI.classList.add('hidden');
        
        // Notify the game
        fetch(`https://${GetParentResourceName()}/selectTeam`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ team })
        });
    }
    
    showTeamSelection() {
        this.teamUI.classList.remove('hidden');
    }
    
    showMissions(missions) {
        this.missionUI.classList.remove('hidden');
        this.renderMissions(missions);
    }
    
    showDistricts(districts) {
        this.districtUI.classList.remove('hidden');
        this.renderDistricts(districts);
    }
    
    renderMissions(missions) {
        const container = document.getElementById('mission-container');
        if (!missions || missions.length === 0) {
            container.innerHTML = '<div class="text-center text-gray-400">No missions available in this district</div>';
            return;
        }
        container.innerHTML = missions.map(mission => this.createMissionCard(mission)).join('');
    }
    
    renderDistricts(districts) {
        const container = document.getElementById('district-container');
        container.innerHTML = districts.map(district => this.createDistrictCard(district)).join('');
    }
    
    createMissionCard(mission) {
        return `
            <div class="mission-card" data-id="${mission.id}">
                <div class="flex justify-between items-start">
                    <h3 class="text-gradient">${mission.title}</h3>
                    <span class="badge ${mission.type}">${mission.type.toUpperCase()}</span>
                </div>
                <p class="text-gray-300 mt-2">${mission.description}</p>
                <div class="flex justify-between items-center mt-4">
                    <div class="flex items-center gap-2">
                        <i class="ri-money-dollar-circle-line text-yellow-400"></i>
                        <span class="font-semibold">$${mission.reward.toLocaleString()}</span>
                    </div>
                    <button onclick="window.dzUI.acceptMission('${mission.id}')" class="btn btn-primary btn-sm">
                        Accept Mission
                    </button>
                </div>
            </div>
        `;
    }
    
    createDistrictCard(district) {
        const isCurrentDistrict = this.currentDistrict && district.id === this.currentDistrict.id;
        const influence = district.influence || 0;
        
        return `
            <div class="district-card ${isCurrentDistrict ? 'current' : ''}" data-id="${district.id}">
                <h3 class="text-gradient">${district.name}</h3>
                <p class="text-gray-300 mt-2">${district.description}</p>
                <div class="mt-4 space-y-2">
                    <div class="flex justify-between items-center">
                        <span class="text-sm text-gray-400">Status</span>
                        <span class="badge ${isCurrentDistrict ? 'current' : 'neutral'}">
                            ${isCurrentDistrict ? 'CURRENT DISTRICT' : 'NEUTRAL'}
                        </span>
                    </div>
                    <div class="space-y-1">
                        <div class="flex justify-between text-sm">
                            <span class="text-gray-400">Influence</span>
                            <span>${influence}%</span>
                        </div>
                        <div class="progress-bar">
                            <div class="progress-bar-fill" style="width: ${influence}%"></div>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }
    
    acceptMission(missionId) {
        if (!this.currentTeam) {
            this.showNotification('You must select a team first!', 'error');
            return;
        }
        
        fetch(`https://${GetParentResourceName()}/acceptMission`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ missionId })
        });
    }
    
    showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.innerHTML = `
            <div class="flex items-center gap-2">
                <i class="ri-${this.getNotificationIcon(type)}-line"></i>
                <span>${message}</span>
            </div>
        `;
        
        this.notifications.appendChild(notification);
        
        setTimeout(() => {
            notification.classList.add('fade-out');
            setTimeout(() => notification.remove(), 300);
        }, 3000);
    }
    
    getNotificationIcon(type) {
        switch (type) {
            case 'success': return 'check-double';
            case 'error': return 'error-warning';
            case 'warning': return 'alert';
            default: return 'information';
        }
    }
}

// Initialize UI
window.dzUI = new DistrictZeroUI(); 