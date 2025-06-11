<template>
  <div class="factions-container">
    <div class="factions-header">
      <h1>{{ $t('factions.title') }}</h1>
      <button @click="openCreateModal" class="btn-create">{{ $t('factions.create') }}</button>
    </div>

    <div class="factions-list">
      <div v-for="faction in factions" :key="faction.id" class="faction-card">
        <div class="faction-info">
          <h2>{{ faction.name }}</h2>
          <p>{{ faction.description }}</p>
          <div class="faction-stats">
            <span>{{ $t('factions.members') }}: {{ faction.memberCount }}</span>
            <span>{{ $t('factions.level') }}: {{ faction.level }}</span>
          </div>
        </div>
        <div class="faction-actions">
          <button @click="editFaction(faction)" class="btn-edit">{{ $t('common.edit') }}</button>
          <button @click="deleteFaction(faction.id)" class="btn-delete">
            {{ $t('common.delete') }}
          </button>
        </div>
      </div>
    </div>

    <!-- Create/Edit Modal -->
    <div v-if="showModal" class="modal">
      <div class="modal-content">
        <h2>{{ isEditing ? $t('factions.edit') : $t('factions.create') }}</h2>
        <form @submit.prevent="saveFaction">
          <div class="form-group">
            <label>{{ $t('factions.name') }}</label>
            <input v-model="currentFaction.name" required />
          </div>
          <div class="form-group">
            <label>{{ $t('factions.description') }}</label>
            <textarea v-model="currentFaction.description" required></textarea>
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
  name: 'Factions',
  data() {
    return {
      factions: [],
      showModal: false,
      isEditing: false,
      currentFaction: {
        id: null,
        name: '',
        description: '',
      },
    };
  },
  mounted() {
    this.fetchFactions();
    this.setupNuiCallbacks();
  },
  methods: {
    async fetchFactions() {
      try {
        const response = await fetch('https://district-zero/factions/list');
        this.factions = await response.json();
      } catch (error) {
        console.error('Failed to fetch factions:', error);
      }
    },
    setupNuiCallbacks() {
      window.addEventListener('message', (event) => {
        const data = event.data;
        if (data.action === 'updateFactions') {
          this.factions = data.factions;
        }
      });
    },
    openCreateModal() {
      this.isEditing = false;
      this.currentFaction = {
        id: null,
        name: '',
        description: '',
      };
      this.showModal = true;
    },
    editFaction(faction) {
      this.isEditing = true;
      this.currentFaction = { ...faction };
      this.showModal = true;
    },
    async saveFaction() {
      try {
        const endpoint = this.isEditing ? 'update' : 'create';
        const response = await fetch(`https://district-zero/factions/${endpoint}`, {
          method: 'POST',
          body: JSON.stringify(this.currentFaction),
        });
        if (response.ok) {
          this.fetchFactions();
          this.closeModal();
        }
      } catch (error) {
        console.error('Failed to save faction:', error);
      }
    },
    async deleteFaction(id) {
      if (confirm(this.$t('factions.confirmDelete'))) {
        try {
          const response = await fetch(`https://district-zero/factions/delete`, {
            method: 'POST',
            body: JSON.stringify({ id }),
          });
          if (response.ok) {
            this.fetchFactions();
          }
        } catch (error) {
          console.error('Failed to delete faction:', error);
        }
      }
    },
    closeModal() {
      this.showModal = false;
      this.currentFaction = {
        id: null,
        name: '',
        description: '',
      };
    },
  },
};
</script>

<style scoped>
.factions-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.factions-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.factions-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.faction-card {
  background: rgba(0, 0, 0, 0.8);
  border-radius: 8px;
  padding: 15px;
  color: white;
}

.faction-info h2 {
  margin: 0 0 10px 0;
  color: #fff;
}

.faction-stats {
  display: flex;
  gap: 15px;
  margin-top: 10px;
  font-size: 0.9em;
  color: #ccc;
}

.faction-actions {
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
.form-group textarea {
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

.btn-save {
  background: #4caf50;
  color: white;
}

.btn-cancel {
  background: #666;
  color: white;
}
</style>
