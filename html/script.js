// UI State
let state = {
  currentMenu: null,
  data: null,
};

// UI Elements
const app = document.getElementById('app');
const menus = {
  main: document.getElementById('main-menu'),
  districts: document.getElementById('districts-menu'),
  missions: document.getElementById('missions-menu'),
  factions: document.getElementById('factions-menu'),
  abilities: document.getElementById('abilities-menu'),
};
const notifications = document.getElementById('notifications');

// Event Listeners
document.addEventListener('DOMContentLoaded', () => {
  // Menu item clicks
  document.querySelectorAll('.menu-item').forEach((item) => {
    item.addEventListener('click', () => {
      const action = item.dataset.action;
      const value = item.dataset.value;
      sendNUIMessage({ action, value });
    });
  });

  // Button clicks
  document.querySelectorAll('.btn').forEach((btn) => {
    btn.addEventListener('click', () => {
      const action = btn.dataset.action;
      sendNUIMessage({ action });
    });
  });
});

// NUI Message Handler
window.addEventListener('message', (event) => {
  const data = event.data;

  switch (data.action) {
    case 'show':
      showMenu(data.menu, data.data);
      break;
    case 'hide':
      hideMenu();
      break;
    case 'update':
      updateMenu(data.data);
      break;
    case 'notification':
      showNotification(data.id, data.message, data.type);
      break;
    case 'removeNotification':
      removeNotification(data.id);
      break;
  }
});

// Menu Functions
function showMenu(menu, data) {
  state.currentMenu = menu;
  state.data = data;

  // Show app
  app.classList.remove('hidden');

  // Hide all menus
  Object.values(menus).forEach((m) => m.classList.add('hidden'));

  // Show selected menu
  if (menus[menu]) {
    menus[menu].classList.remove('hidden');
    updateMenuContent(menu, data);
  }
}

function hideMenu() {
  state.currentMenu = null;
  state.data = null;
  app.classList.add('hidden');
}

function updateMenu(data) {
  state.data = data;
  if (state.currentMenu) {
    updateMenuContent(state.currentMenu, data);
  }
}

function updateMenuContent(menu, data) {
  const content = document.getElementById(`${menu}-list`);
  if (!content) return;

  // Clear content
  content.innerHTML = '';

  // Add items based on menu type
  switch (menu) {
    case 'districts':
      updateDistrictsList(content, data);
      break;
    case 'missions':
      updateMissionsList(content, data);
      break;
    case 'factions':
      updateFactionsList(content, data);
      break;
    case 'abilities':
      updateAbilitiesList(content, data);
      break;
  }
}

// List Update Functions
function updateDistrictsList(container, districts) {
  if (!districts) return;

  Object.entries(districts).forEach(([id, district]) => {
    const item = document.createElement('div');
    item.className = 'menu-item';
    item.dataset.action = 'select';
    item.dataset.value = id;

    item.innerHTML = `
            <span class="icon">🗺️</span>
            <span class="text">${district.name}</span>
            <span class="status">${district.status}</span>
        `;

    container.appendChild(item);
  });
}

function updateMissionsList(container, missions) {
  if (!missions) return;

  Object.entries(missions).forEach(([id, mission]) => {
    const item = document.createElement('div');
    item.className = 'menu-item';
    item.dataset.action = 'select';
    item.dataset.value = id;

    item.innerHTML = `
            <span class="icon">🎯</span>
            <span class="text">${mission.name}</span>
            <span class="status">${mission.status}</span>
        `;

    container.appendChild(item);
  });
}

function updateFactionsList(container, factions) {
  if (!factions) return;

  Object.entries(factions).forEach(([id, faction]) => {
    const item = document.createElement('div');
    item.className = 'menu-item';
    item.dataset.action = 'select';
    item.dataset.value = id;

    item.innerHTML = `
            <span class="icon">👥</span>
            <span class="text">${faction.name}</span>
            <span class="status">${faction.status}</span>
        `;

    container.appendChild(item);
  });
}

function updateAbilitiesList(container, abilities) {
  if (!abilities) return;

  Object.entries(abilities).forEach(([id, ability]) => {
    const item = document.createElement('div');
    item.className = 'menu-item';
    item.dataset.action = 'select';
    item.dataset.value = id;

    item.innerHTML = `
            <span class="icon">⚡</span>
            <span class="text">${ability.name}</span>
            <span class="status">${ability.status}</span>
        `;

    container.appendChild(item);
  });
}

// Notification Functions
function showNotification(id, message, type) {
  const notification = document.createElement('div');
  notification.id = `notification-${id}`;
  notification.className = `notification ${type}`;
  notification.textContent = message;

  notifications.appendChild(notification);

  // Remove notification after 5 seconds
  setTimeout(() => {
    removeNotification(id);
  }, 5000);
}

function removeNotification(id) {
  const notification = document.getElementById(`notification-${id}`);
  if (notification) {
    notification.style.animation = 'slideOut 0.3s ease';
    setTimeout(() => {
      notification.remove();
    }, 300);
  }
}

// NUI Message Function
function sendNUIMessage(data) {
  fetch(`https://${GetParentResourceName()}/nui`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(data),
  });
}
