// Districts UI Handler
const state = {
    districts: {},
    currentDistrict: null,
    selectedDistrict: null,
    mapScale: 1,
    mapOffset: { x: 0, y: 0 },
    isDragging: false,
    lastMousePos: { x: 0, y: 0 }
};

// UI Elements
const elements = {
    mapZones: document.getElementById('mapZones'),
    districtList: document.getElementById('districtList'),
    districtDetails: document.getElementById('districtDetails'),
    currentDistrict: document.getElementById('currentDistrict'),
    searchInput: document.getElementById('districtSearch'),
    sortSelect: document.getElementById('districtSort'),
    filterButtons: document.querySelectorAll('.filter-button'),
    mapControls: {
        zoomIn: document.getElementById('zoomIn'),
        zoomOut: document.getElementById('zoomOut'),
        resetView: document.getElementById('resetView')
    },
    detailButtons: {
        close: document.getElementById('closeDetails'),
        capture: document.getElementById('actionCapture'),
        defend: document.getElementById('actionDefend'),
        upgrade: document.getElementById('actionUpgrade')
    }
};

// Initialize
function init() {
    loadDistricts();
    setupEventListeners();
    setupMapControls();
}

// Load districts from server
function loadDistricts() {
    fetch(`https://${GetParentResourceName()}/getDistricts`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).then(resp => resp.json())
    .then(districts => {
        state.districts = districts;
        renderDistricts();
        renderMapZones();
    });
}

// Render districts list
function renderDistricts() {
    const filteredDistricts = filterDistricts();
    const sortedDistricts = sortDistricts(filteredDistricts);
    
    elements.districtList.innerHTML = sortedDistricts.map(district => `
        <div class="district-item" data-id="${district.id}">
            <h4>${district.name}</h4>
            <div class="district-item-info">
                <span class="district-type">${district.type}</span>
                <span class="district-control">${district.control}</span>
            </div>
        </div>
    `).join('');

    // Add click handlers
    document.querySelectorAll('.district-item').forEach(item => {
        item.addEventListener('click', () => {
            const districtId = item.dataset.id;
            showDistrictDetails(districtId);
        });
    });
}

// Render map zones
function renderMapZones() {
    elements.mapZones.innerHTML = Object.values(state.districts).map(district => `
        <div class="zone ${district.control.toLowerCase()}" 
             style="left: ${district.center.x}px; 
                    top: ${district.center.y}px; 
                    width: ${district.radius * 2}px; 
                    height: ${district.radius * 2}px;"
             data-id="${district.id}">
        </div>
    `).join('');

    // Add click handlers
    document.querySelectorAll('.zone').forEach(zone => {
        zone.addEventListener('click', () => {
            const districtId = zone.dataset.id;
            showDistrictDetails(districtId);
        });
    });
}

// Filter districts
function filterDistricts() {
    const activeFilter = document.querySelector('.filter-button.active').dataset.filter;
    const searchTerm = elements.searchInput.value.toLowerCase();

    return Object.values(state.districts).filter(district => {
        const matchesFilter = activeFilter === 'all' || district.control.toLowerCase() === activeFilter;
        const matchesSearch = district.name.toLowerCase().includes(searchTerm);
        return matchesFilter && matchesSearch;
    });
}

// Sort districts
function sortDistricts(districts) {
    const sortBy = elements.sortSelect.value;
    return districts.sort((a, b) => {
        if (sortBy === 'name') {
            return a.name.localeCompare(b.name);
        }
        return a[sortBy].localeCompare(b[sortBy]);
    });
}

// Show district details
function showDistrictDetails(districtId) {
    const district = state.districts[districtId];
    if (!district) return;

    state.selectedDistrict = districtId;
    
    // Update details
    document.getElementById('detailName').textContent = district.name;
    document.getElementById('detailType').textContent = district.type;
    document.getElementById('detailControl').textContent = district.control;
    document.getElementById('detailPopulation').textContent = district.population || 'N/A';
    document.getElementById('detailIncome').textContent = district.income || 'N/A';
    document.getElementById('detailDefense').textContent = district.defense || 'N/A';

    // Show details panel
    elements.districtDetails.style.display = 'block';
}

// Update current district
function updateCurrentDistrict(district) {
    if (!district) {
        elements.currentDistrict.querySelector('.district-name').textContent = 'Not in any district';
        elements.currentDistrict.querySelector('.district-type').textContent = 'Type: None';
        elements.currentDistrict.querySelector('.district-control').textContent = 'Control: None';
        return;
    }

    elements.currentDistrict.querySelector('.district-name').textContent = district.name;
    elements.currentDistrict.querySelector('.district-type').textContent = `Type: ${district.type}`;
    elements.currentDistrict.querySelector('.district-control').textContent = `Control: ${district.control}`;
}

// Map Controls
function setupMapControls() {
    // Zoom controls
    elements.mapControls.zoomIn.addEventListener('click', () => {
        state.mapScale = Math.min(state.mapScale * 1.2, 3);
        updateMapTransform();
    });

    elements.mapControls.zoomOut.addEventListener('click', () => {
        state.mapScale = Math.max(state.mapScale / 1.2, 0.5);
        updateMapTransform();
    });

    elements.mapControls.resetView.addEventListener('click', () => {
        state.mapScale = 1;
        state.mapOffset = { x: 0, y: 0 };
        updateMapTransform();
    });

    // Pan controls
    elements.mapZones.addEventListener('mousedown', (e) => {
        state.isDragging = true;
        state.lastMousePos = { x: e.clientX, y: e.clientY };
    });

    document.addEventListener('mousemove', (e) => {
        if (!state.isDragging) return;
        
        const dx = e.clientX - state.lastMousePos.x;
        const dy = e.clientY - state.lastMousePos.y;
        
        state.mapOffset.x += dx;
        state.mapOffset.y += dy;
        
        state.lastMousePos = { x: e.clientX, y: e.clientY };
        updateMapTransform();
    });

    document.addEventListener('mouseup', () => {
        state.isDragging = false;
    });
}

function updateMapTransform() {
    elements.mapZones.style.transform = `translate(${state.mapOffset.x}px, ${state.mapOffset.y}px) scale(${state.mapScale})`;
}

// Event Listeners
function setupEventListeners() {
    // Filter buttons
    elements.filterButtons.forEach(button => {
        button.addEventListener('click', () => {
            elements.filterButtons.forEach(btn => btn.classList.remove('active'));
            button.classList.add('active');
            renderDistricts();
        });
    });

    // Search input
    elements.searchInput.addEventListener('input', renderDistricts);

    // Sort select
    elements.sortSelect.addEventListener('change', renderDistricts);

    // Detail buttons
    elements.detailButtons.close.addEventListener('click', () => {
        elements.districtDetails.style.display = 'none';
        state.selectedDistrict = null;
    });

    elements.detailButtons.capture.addEventListener('click', () => {
        if (!state.selectedDistrict) return;
        fetch(`https://${GetParentResourceName()}/captureDistrict`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ districtId: state.selectedDistrict })
        });
    });

    elements.detailButtons.defend.addEventListener('click', () => {
        if (!state.selectedDistrict) return;
        fetch(`https://${GetParentResourceName()}/defendDistrict`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ districtId: state.selectedDistrict })
        });
    });

    elements.detailButtons.upgrade.addEventListener('click', () => {
        if (!state.selectedDistrict) return;
        fetch(`https://${GetParentResourceName()}/upgradeDistrict`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ districtId: state.selectedDistrict })
        });
    });
}

// NUI Message Handler
window.addEventListener('message', (event) => {
    const data = event.data;

    switch (data.action) {
        case 'updateDistricts':
            state.districts = data.districts;
            renderDistricts();
            renderMapZones();
            break;

        case 'updateCurrentDistrict':
            state.currentDistrict = data.district;
            updateCurrentDistrict(data.district);
            break;
    }
});

// Initialize on load
document.addEventListener('DOMContentLoaded', init); 