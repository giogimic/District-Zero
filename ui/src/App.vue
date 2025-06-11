<template>
  <div id="app">
    <nav class="main-nav">
      <button
        v-for="page in pages"
        :key="page.id"
        @click="currentPage = page.id"
        :class="{ active: currentPage === page.id }"
      >
        <font-awesome-icon :icon="page.icon" class="nav-icon" />
        {{ $t(`nav.${page.id}`) }}
      </button>
    </nav>

    <main class="main-content">
      <component :is="currentComponent" />
    </main>
  </div>
</template>

<script>
import Factions from './components/Factions.vue';
import Events from './components/Events.vue';

export default {
  name: 'App',
  components: {
    Factions,
    Events,
  },
  data() {
    return {
      currentPage: 'factions',
      pages: [
        { id: 'factions', component: 'Factions', icon: 'users' },
        { id: 'events', component: 'Events', icon: 'calendar-alt' },
      ],
    };
  },
  computed: {
    currentComponent() {
      const page = this.pages.find((p) => p.id === this.currentPage);
      return page ? page.component : 'Factions';
    },
  },
  mounted() {
    this.setupNuiCallbacks();
  },
  methods: {
    setupNuiCallbacks() {
      window.addEventListener('message', (event) => {
        const data = event.data;
        if (data.action === 'openPage') {
          this.currentPage = data.page;
        }
      });
    },
  },
};
</script>

<style>
#app {
  font-family: 'Arial', sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: white;
  height: 100vh;
  display: flex;
  flex-direction: column;
}

.main-nav {
  background: rgba(0, 0, 0, 0.9);
  padding: 10px 20px;
  display: flex;
  gap: 10px;
}

.main-nav button {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  background: transparent;
  color: white;
  cursor: pointer;
  font-weight: bold;
  transition: background-color 0.2s;
}

.main-nav button:hover {
  background: rgba(255, 255, 255, 0.1);
}

.main-nav button.active {
  background: #2196f3;
}

.main-content {
  flex: 1;
  overflow-y: auto;
  background: rgba(0, 0, 0, 0.8);
}

/* Global styles */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  background: transparent;
}

/* Scrollbar styling */
::-webkit-scrollbar {
  width: 8px;
}

::-webkit-scrollbar-track {
  background: rgba(0, 0, 0, 0.2);
}

::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.2);
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.3);
}

.nav-icon {
  margin-right: 8px;
}
</style>
