import { createApp } from 'vue';
import App from './App.vue';
import { createI18n } from 'vue-i18n';

// Create Vue app
const app = createApp(App);

// Create i18n instance
const i18n = createI18n({
  legacy: false,
  locale: 'en',
  fallbackLocale: 'en',
  messages: {},
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
    app.mount('#app');
  })
  .catch((error) => {
    console.error('Failed to load translations:', error);
    app.use(i18n);
    app.mount('#app');
  });

// Handle NUI messages
window.addEventListener('message', (event) => {
  const data = event.data;

  if (data.action === 'updateLocale') {
    i18n.global.setLocaleMessage('en', data.locale);
  }
});
