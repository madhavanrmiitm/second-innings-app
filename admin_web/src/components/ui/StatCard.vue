<template>
  <div class="card stat-card h-100">
    <div class="card-body">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <h6 class="text-muted mb-2">{{ title }}</h6>
          <h3 class="mb-0">{{ value }}</h3>
        </div>
        <div :class="`text-${color}`">
          <i :class="`bi bi-${iconMap[icon]} fs-1`"></i>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  title: String,
  value: [String, Number],
  icon: String,
  color: {
    type: String,
    default: 'primary'
  }
})

const iconMap = {
  'users': 'people-fill',
  'user-check': 'person-check-fill',
  'ticket': 'ticket-perforated-fill',
  'bell': 'bell-fill'
}
</script>