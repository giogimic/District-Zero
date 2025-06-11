<template>
  <div class="events-container">
    <div class="events-header">
      <h1>{{ $t('events.title') }}</h1>
      <div class="events-controls">
        <button @click="openCreateModal" class="btn-create">{{ $t('events.create') }}</button>
        <select v-model="selectedDistrict" class="district-select">
          <option value="">{{ $t('events.allDistricts') }}</option>
          <option v-for="district in districts" :key="district.id" :value="district.id">
            {{ district.name }}
          </option>
        </select>
      </div>
    </div>

    <div class="events-list">
      <div v-for="event in filteredEvents" :key="event.id" class="event-card">
        <div class="event-info">
          <h2>{{ event.name }}</h2>
          <p>{{ event.description }}</p>
          <div class="event-details">
            <span class="district">{{ getDistrictName(event.districtId) }}</span>
            <span class="time"
              >{{ formatTime(event.startTime) }} - {{ formatTime(event.endTime) }}</span
            >
            <span class="status" :class="event.status">{{
              $t(`events.status.${event.status}`)
            }}</span>
          </div>
        </div>
        <div class="event-actions">
          <button @click="editEvent(event)" class="btn-edit">{{ $t('common.edit') }}</button>
          <button @click="deleteEvent(event.id)" class="btn-delete">
            {{ $t('common.delete') }}
          </button>
          <button
            v-if="event.status === 'scheduled'"
            @click="startEvent(event.id)"
            class="btn-start"
          >
            {{ $t('events.start') }}
          </button>
        </div>
      </div>
    </div>

    <!-- Create/Edit Modal -->
    <div v-if="showModal" class="modal">
      <div class="modal-content">
        <h2>{{ isEditing ? $t('events.edit') : $t('events.create') }}</h2>
        <form @submit.prevent="saveEvent">
          <div class="form-group">
            <label>{{ $t('events.name') }}</label>
            <input v-model="currentEvent.name" required />
          </div>
          <div class="form-group">
            <label>{{ $t('events.description') }}</label>
            <textarea v-model="currentEvent.description" required></textarea>
          </div>
          <div class="form-group">
            <label>{{ $t('events.district') }}</label>
            <select v-model="currentEvent.districtId" required>
              <option v-for="district in districts" :key="district.id" :value="district.id">
                {{ district.name }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label>{{ $t('events.startTime') }}</label>
            <input type="datetime-local" v-model="currentEvent.startTime" required />
          </div>
          <div class="form-group">
            <label>{{ $t('events.endTime') }}</label>
            <input type="datetime-local" v-model="currentEvent.endTime" required />
          </div>
          <div class="form-actions">
            <button type="submit" class="btn-save">{{ $t('common.save') }}</button>
            <button type="button" @click="closeModal" class="btn-cancel">
              {{ $t('common.cancel') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Events',
  data() {
    return {
      events: [],
      districts: [],
      showModal: false,
      isEditing: false,
      selectedDistrict: '',
      currentEvent: {
        id: null,
        name: '',
        description: '',
        districtId: '',
        startTime: '',
        endTime: '',
        status: 'scheduled',
      },
    };
  },
  computed: {
    filteredEvents() {
      if (!this.selectedDistrict) return this.events;
      return this.events.filter((event) => event.districtId === this.selectedDistrict);
    },
  },
  mounted() {
    this.fetchEvents();
    this.fetchDistricts();
    this.setupNuiCallbacks();
  },
  methods: {
    async fetchEvents() {
      try {
        const response = await fetch('https://district-zero/events/list');
        this.events = await response.json();
      } catch (error) {
        console.error('Failed to fetch events:', error);
      }
    },
    async fetchDistricts() {
      try {
        const response = await fetch('https://district-zero/districts/list');
        this.districts = await response.json();
      } catch (error) {
        console.error('Failed to fetch districts:', error);
      }
    },
    setupNuiCallbacks() {
      window.addEventListener('message', (event) => {
        const data = event.data;
        if (data.action === 'updateEvents') {
          this.events = data.events;
        }
      });
    },
    getDistrictName(districtId) {
      const district = this.districts.find((d) => d.id === districtId);
      return district ? district.name : 'Unknown District';
    },
    formatTime(time) {
      return new Date(time).toLocaleString();
    },
    openCreateModal() {
      this.isEditing = false;
      this.currentEvent = {
        id: null,
        name: '',
        description: '',
        districtId: '',
        startTime: '',
        endTime: '',
        status: 'scheduled',
      };
      this.showModal = true;
    },
    editEvent(event) {
      this.isEditing = true;
      this.currentEvent = { ...event };
      this.showModal = true;
    },
    async saveEvent() {
      try {
        const endpoint = this.isEditing ? 'update' : 'create';
        const response = await fetch(`https://district-zero/events/${endpoint}`, {
          method: 'POST',
          body: JSON.stringify(this.currentEvent),
        });
        if (response.ok) {
          this.fetchEvents();
          this.closeModal();
        }
      } catch (error) {
        console.error('Failed to save event:', error);
      }
    },
    async deleteEvent(id) {
      if (confirm(this.$t('events.confirmDelete'))) {
        try {
          const response = await fetch(`https://district-zero/events/delete`, {
            method: 'POST',
            body: JSON.stringify({ id }),
          });
          if (response.ok) {
            this.fetchEvents();
          }
        } catch (error) {
          console.error('Failed to delete event:', error);
        }
      }
    },
    async startEvent(id) {
      try {
        const response = await fetch(`https://district-zero/events/start`, {
          method: 'POST',
          body: JSON.stringify({ id }),
        });
        if (response.ok) {
          this.fetchEvents();
        }
      } catch (error) {
        console.error('Failed to start event:', error);
      }
    },
    closeModal() {
      this.showModal = false;
      this.currentEvent = {
        id: null,
        name: '',
        description: '',
        districtId: '',
        startTime: '',
        endTime: '',
        status: 'scheduled',
      };
    },
  },
};
</script>

<style scoped>
.events-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.events-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.events-controls {
  display: flex;
  gap: 10px;
}

.district-select {
  padding: 8px;
  border-radius: 4px;
  background: #2a2a2a;
  color: white;
  border: 1px solid #333;
}

.events-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.event-card {
  background: rgba(0, 0, 0, 0.8);
  border-radius: 8px;
  padding: 15px;
  color: white;
}

.event-info h2 {
  margin: 0 0 10px 0;
  color: #fff;
}

.event-details {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 10px;
  font-size: 0.9em;
}

.event-details span {
  padding: 4px 8px;
  border-radius: 4px;
  background: rgba(255, 255, 255, 0.1);
}

.status {
  text-transform: capitalize;
}

.status.scheduled {
  background: #2196f3;
}

.status.active {
  background: #4caf50;
}

.status.completed {
  background: #9e9e9e;
}

.event-actions {
  display: flex;
  gap: 10px;
  margin-top: 15px;
}

.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-content {
  background: #1a1a1a;
  padding: 20px;
  border-radius: 8px;
  width: 90%;
  max-width: 500px;
}

.form-group {
  margin-bottom: 15px;
}

.form-group label {
  display: block;
  margin-bottom: 5px;
  color: #fff;
}

.form-group input,
.form-group textarea,
.form-group select {
  width: 100%;
  padding: 8px;
  border: 1px solid #333;
  border-radius: 4px;
  background: #2a2a2a;
  color: #fff;
}

.form-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
  margin-top: 20px;
}

button {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: bold;
}

.btn-create {
  background: #4caf50;
  color: white;
}

.btn-edit {
  background: #2196f3;
  color: white;
}

.btn-delete {
  background: #f44336;
  color: white;
}

.btn-start {
  background: #ff9800;
  color: white;
}

.btn-save {
  background: #4caf50;
  color: white;
}

.btn-cancel {
  background: #666;
  color: white;
}
</style>
