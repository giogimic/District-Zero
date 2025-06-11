<template>
  <div id="app" :class="{ hidden: !isVisible }">
    <!-- Loading State -->
    <div v-if="isLoading" class="loading">
      <div class="loading-spinner"></div>
      <div class="loading-text">Loading...</div>
    </div>

    <!-- Main Menu -->
    <div v-else-if="currentMenu === 'main'" class="menu">
      <div class="menu-header">
        <h1>District Zero</h1>
      </div>
      <div class="menu-content">
        <div
          v-for="item in menuItems"
          :key="item.id"
          class="menu-item"
          @click="handleMenuClick(item)"
        >
          <span class="icon">{{ item.icon }}</span>
          <span class="text">{{ item.text }}</span>
        </div>
      </div>
      <div class="menu-footer">
        <button class="btn" @click="handleBack">Back</button>
      </div>
    </div>

    <!-- Other Menus -->
    <div v-else class="menu">
      <div class="menu-header">
        <h2>{{ currentMenu.charAt(0).toUpperCase() + currentMenu.slice(1) }}</h2>
      </div>
      <div class="menu-content">
        <div
          v-for="item in menuData"
          :key="item.id"
          class="menu-item"
          @click="handleItemClick(item)"
        >
          <span class="icon">{{ item.icon }}</span>
          <span class="text">{{ item.name }}</span>
          <span class="status">{{ item.status }}</span>
        </div>
      </div>
      <div class="menu-footer">
        <button class="btn" @click="handleBack">Back</button>
      </div>
    </div>

    <!-- Notifications -->
    <div id="notifications">
      <div
        v-for="notification in notifications"
        :key="notification.id"
        :class="['notification', notification.type]"
      >
        {{ notification.message }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'App',
  data() {
    return {
      isVisible: false,
      isLoading: true,
      currentMenu: 'main',
      menuData: [],
      notifications: [],
      menuItems: [
        { id: 'districts', text: 'Districts', icon: '🗺️' },
        { id: 'missions', text: 'Missions', icon: '🎯' },
        { id: 'factions', text: 'Factions', icon: '👥' },
        { id: 'abilities', text: 'Abilities', icon: '⚡' },
      ],
    };
  },
  mounted() {
    window.addEventListener('message', this.handleMessage);
  },
  beforeUnmount() {
    window.removeEventListener('message', this.handleMessage);
  },
  methods: {
    handleMessage(event) {
      const data = event.data;

      switch (data.action) {
        case 'show':
          this.showMenu(data.menu, data.data);
          break;
        case 'hide':
          this.hideMenu();
          break;
        case 'update':
          this.updateMenu(data.data);
          break;
        case 'notification':
          this.showNotification(data.id, data.message, data.type);
          break;
        case 'removeNotification':
          this.removeNotification(data.id);
          break;
        case 'loading':
          this.setLoading(data.isLoading);
          break;
      }
    },
    showMenu(menu, data) {
      this.currentMenu = menu;
      this.menuData = data;
      this.isVisible = true;
      this.isLoading = false;
    },
    hideMenu() {
      this.isVisible = false;
      this.currentMenu = 'main';
      this.menuData = [];
    },
    updateMenu(data) {
      this.menuData = data;
    },
    handleMenuClick(item) {
      this.sendNUIMessage({ action: 'select', value: item.id });
    },
    handleItemClick(item) {
      this.sendNUIMessage({ action: 'select', value: item.id });
    },
    handleBack() {
      this.sendNUIMessage({ action: 'back' });
    },
    showNotification(id, message, type) {
      this.notifications.push({ id, message, type });
      setTimeout(() => this.removeNotification(id), 5000);
    },
    removeNotification(id) {
      this.notifications = this.notifications.filter((n) => n.id !== id);
    },
    setLoading(isLoading) {
      this.isLoading = isLoading;
    },
    sendNUIMessage(data) {
      fetch(`https://${GetParentResourceName()}/nui`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
      });
    },
  },
};
</script>

<style>
@import './style.css';
</style>
