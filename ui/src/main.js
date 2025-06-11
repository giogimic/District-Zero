import { createApp } from 'vue';
import App from './App.vue';
import { createI18n } from 'vue-i18n';
import messages from './locales/en.json';
import { library } from '@fortawesome/fontawesome-svg-core';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { 
  faUsers, 
  faCalendarAlt, 
  faEdit, 
  faTrash, 
  faPlus, 
  faSave, 
  faTimes,
  faPlay,
  faMapMarkerAlt,
  faClock,
  faChartLine
} from '@fortawesome/free-solid-svg-icons';

// Add icons to library
library.add(
  faUsers,
  faCalendarAlt,
  faEdit,
  faTrash,
  faPlus,
  faSave,
  faTimes,
  faPlay,
  faMapMarkerAlt,
  faClock,
  faChartLine
);

// Create Vue app
const app = createApp(App);

// Create i18n instance
const i18n = createI18n({
  legacy: false,
  locale: 'en',
  fallbackLocale: 'en',
  messages
});

// Load translations from Qbox
fetch(`https://${GetParentResourceName()}/getLocale`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({}),
})
  .then((response) => response.json())
  .then((data) => {
    i18n.global.setLocaleMessage('en', data);
    app.use(i18n);
    app.component('font-awesome-icon', FontAwesomeIcon);
    app.mount('#app');
  })
  .catch((error) => {
    console.error('Failed to load translations:', error);
    app.use(i18n);
    app.component('font-awesome-icon', FontAwesomeIcon);
    app.mount('#app');
  });

// Handle NUI messages
window.addEventListener('message', (event) => {
  const data = event.data;

  if (data.action === 'updateLocale') {
    i18n.global.setLocaleMessage('en', data.locale);
  }
});
