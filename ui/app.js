// NUI Message Handler
window.addEventListener('message', function (event) {
  const data = event.data;

  switch (data.type) {
    case 'show':
      document.getElementById('app').classList.remove('hidden');
      break;

    case 'hide':
      document.getElementById('app').classList.add('hidden');
      break;

    case 'updateDistrict':
      updateDistrictInfo(data.district);
      break;

    case 'updateMissions':
      updateMissionList(data.missions);
      break;

    case 'updateFaction':
      updateFactionInfo(data.faction);
      break;
  }
});

// Update District Information
function updateDistrictInfo(district) {
  const details = document.getElementById('district-details');
  if (!details) return;

  details.innerHTML = `
        <div class="district-name">${district.name}</div>
        <div class="district-owner">Owner: ${district.owner || 'None'}</div>
        <div class="district-control">Control: ${district.control}%</div>
        <div class="district-status">Status: ${district.status}</div>
    `;
}

// Update Mission List
function updateMissionList(missions) {
  const list = document.getElementById('mission-list');
  if (!list) return;

  list.innerHTML = missions
    .map(
      (mission) => `
        <div class="mission-item">
            <div class="mission-name">${mission.name}</div>
            <div class="mission-status">${mission.status}</div>
            <div class="mission-reward">$${mission.reward}</div>
        </div>
    `
    )
    .join('');
}

// Update Faction Information
function updateFactionInfo(faction) {
  const details = document.getElementById('faction-details');
  if (!details) return;

  details.innerHTML = `
        <div class="faction-name">${faction.name}</div>
        <div class="faction-members">Members: ${faction.members}</div>
        <div class="faction-territory">Territory: ${faction.territory}</div>
        <div class="faction-influence">Influence: ${faction.influence}%</div>
    `;
}

// Close UI on Escape key
document.addEventListener('keyup', function (event) {
  if (event.key === 'Escape') {
    fetch(`https://${GetParentResourceName()}/close`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({}),
    });
  }
});

// Prevent UI interaction when hidden
document.addEventListener('click', function (event) {
  if (document.getElementById('app').classList.contains('hidden')) {
    event.preventDefault();
    event.stopPropagation();
  }
});
