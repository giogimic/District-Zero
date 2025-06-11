// Districts UI Handler
const state = {
  districts: {},
  currentDistrict: null,
  selectedDistrict: null,
  mapScale: 1,
  mapOffset: { x: 0, y: 0 },
  isDragging: false,
  lastMousePos: { x: 0, y: 0 },
  isVisible: false,
  settings: {
    minimap: {},
    navigation: {},
  },
};

// UI Elements
const elements = {
  container: document.querySelector('.container'),
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
    resetView: document.getElementById('resetView'),
  },
  detailButtons: {
    close: document.getElementById('closeDetails'),
    capture: document.getElementById('actionCapture'),
    defend: document.getElementById('actionDefend'),
    upgrade: document.getElementById('actionUpgrade'),
  },
};

// Initialize
function init() {
  // Hide UI by default
  elements.container.style.display = 'none';

  // Setup event listeners
  setupEventListeners();
  setupMapControls();

  // Listen for NUI messages
  window.addEventListener('message', handleNuiMessage);

  // Setup close handlers
  setupCloseHandlers();
}

// Setup Close Handlers
function setupCloseHandlers() {
  // Close on ESC
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      hideUI();
    }
  });

  // Close button
  elements.detailButtons.close.addEventListener('click', () => {
    hideUI();
  });
}

// Setup Event Listeners
function setupEventListeners() {
  // Search input
  elements.searchInput.addEventListener('input', (e) => {
    filterDistricts(e.target.value);
  });

  // Sort select
  elements.sortSelect.addEventListener('change', (e) => {
    sortDistricts(e.target.value);
  });

  // Filter buttons
  elements.filterButtons.forEach((button) => {
    button.addEventListener('click', () => {
      filterDistrictsByType(button.dataset.type);
    });
  });

  // District list items
  elements.districtList.addEventListener('click', (e) => {
    const districtItem = e.target.closest('.district-item');
    if (districtItem) {
      const districtId = districtItem.dataset.id;
      selectDistrict(districtId);
    }
  });
}

// Setup Map Controls
function setupMapControls() {
  // Zoom controls
  elements.mapControls.zoomIn.addEventListener('click', () => {
    zoomMap(0.1);
  });

  elements.mapControls.zoomOut.addEventListener('click', () => {
    zoomMap(-0.1);
  });

  elements.mapControls.resetView.addEventListener('click', () => {
    resetMapView();
  });

  // Map drag
  elements.mapZones.addEventListener('mousedown', startDrag);
  document.addEventListener('mousemove', handleDrag);
  document.addEventListener('mouseup', endDrag);
}

// Show UI
function showUI(data) {
  state.districts = data.districts || {};
  state.currentDistrict = data.currentDistrict;
  state.settings = data.settings || {};

  elements.container.style.display = 'grid';
  renderDistricts();
  renderMapZones();
  updateCurrentDistrict(state.currentDistrict);
}

// Hide UI
function hideUI() {
  elements.container.style.display = 'none';
  state.isVisible = false;
  state.selectedDistrict = null;
}

// Handle NUI Messages
function handleNuiMessage(event) {
  const data = event.data;

  switch (data.action) {
    case 'show':
      showUI(data);
      break;

    case 'hide':
      hideUI();
      break;

    case 'updateDistricts':
      state.districts = data.districts;
      renderDistricts();
      renderMapZones();
      break;

    case 'updateCurrentDistrict':
      state.currentDistrict = data.district;
      updateCurrentDistrict(data.district);
      break;

    case 'updateSettings':
      state.settings = data.settings;
      updateSettings();
      break;
  }
}

// District Selection
function selectDistrict(districtId) {
  state.selectedDistrict = districtId;
  const district = state.districts[districtId];

  if (district) {
    showDistrictDetails(district);
  }
}

// Show District Details
function showDistrictDetails(district) {
  elements.districtDetails.classList.remove('hidden');

  // Update details content
  document.getElementById('district-name').textContent = district.name;
  document.getElementById('district-control').textContent = district.control;
  document.getElementById('district-influence').textContent = district.influence;

  // Update action buttons
  elements.detailButtons.capture.disabled = !district.canCapture;
  elements.detailButtons.defend.disabled = !district.canDefend;
  elements.detailButtons.upgrade.disabled = !district.canUpgrade;
}

// Map Controls
function startDrag(e) {
  state.isDragging = true;
  state.lastMousePos = { x: e.clientX, y: e.clientY };
}

function handleDrag(e) {
  if (!state.isDragging) return;

  const dx = e.clientX - state.lastMousePos.x;
  const dy = e.clientY - state.lastMousePos.y;

  state.mapOffset.x += dx;
  state.mapOffset.y += dy;

  state.lastMousePos = { x: e.clientX, y: e.clientY };

  updateMapPosition();
}

function endDrag() {
  state.isDragging = false;
}

function zoomMap(delta) {
  state.mapScale = Math.max(0.5, Math.min(2, state.mapScale + delta));
  updateMapScale();
}

function resetMapView() {
  state.mapScale = 1;
  state.mapOffset = { x: 0, y: 0 };
  updateMapPosition();
  updateMapScale();
}

// Map Updates
function updateMapPosition() {
  elements.mapZones.style.transform = `translate(${state.mapOffset.x}px, ${state.mapOffset.y}px)`;
}

function updateMapScale() {
  elements.mapZones.style.transform = `scale(${state.mapScale})`;
}

// District List Updates
function filterDistricts(query) {
  const items = elements.districtList.querySelectorAll('.district-item');

  items.forEach((item) => {
    const name = item.dataset.name.toLowerCase();
    const matches = name.includes(query.toLowerCase());
    item.style.display = matches ? 'block' : 'none';
  });
}

function sortDistricts(sortBy) {
  const items = Array.from(elements.districtList.querySelectorAll('.district-item'));

  items.sort((a, b) => {
    const aValue = a.dataset[sortBy];
    const bValue = b.dataset[sortBy];

    if (sortBy === 'name') {
      return aValue.localeCompare(bValue);
    }

    return Number(bValue) - Number(aValue);
  });

  items.forEach((item) => elements.districtList.appendChild(item));
}

function filterDistrictsByType(type) {
  const items = elements.districtList.querySelectorAll('.district-item');

  items.forEach((item) => {
    const districtType = item.dataset.type;
    const matches = type === 'all' || districtType === type;
    item.style.display = matches ? 'block' : 'none';
  });
}

// Render Functions
function renderDistricts() {
  elements.districtList.innerHTML = '';

  Object.entries(state.districts).forEach(([id, district]) => {
    const item = document.createElement('div');
    item.className = 'district-item';
    item.dataset.id = id;
    item.dataset.name = district.name;
    item.dataset.type = district.type;
    item.dataset.influence = district.influence;

    item.innerHTML = `
            <div class="district-name">${district.name}</div>
            <div class="district-type">${district.type}</div>
            <div class="district-influence">${district.influence}</div>
        `;

    elements.districtList.appendChild(item);
  });
}

function renderMapZones() {
  elements.mapZones.innerHTML = '';

  Object.entries(state.districts).forEach(([id, district]) => {
    const zone = document.createElement('div');
    zone.className = 'map-zone';
    zone.dataset.id = id;

    // Set zone position and size
    zone.style.left = `${district.position.x}%`;
    zone.style.top = `${district.position.y}%`;
    zone.style.width = `${district.size.x}%`;
    zone.style.height = `${district.size.y}%`;

    // Set zone color based on control
    zone.style.backgroundColor = getDistrictColor(district.control);

    elements.mapZones.appendChild(zone);
  });
}

function updateCurrentDistrict(district) {
  if (!district) return;

  elements.currentDistrict.innerHTML = `
        <div class="current-name">${district.name}</div>
        <div class="current-control">${district.control}</div>
        <div class="current-influence">${district.influence}</div>
    `;
}

// Helper Functions
function getDistrictColor(control) {
  const colors = {
    neutral: '#808080',
    player: '#00ff00',
    enemy: '#ff0000',
  };

  return colors[control] || colors.neutral;
}

// Initialize
init();
