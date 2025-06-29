import { createApp } from 'vue'
import { createPinia } from 'pinia'
import VueToast from 'vue-toast-notification'
import 'vue-toast-notification/dist/theme-sugar.css'

// Bootstrap CSS
import 'bootstrap/dist/css/bootstrap.min.css'
import 'bootstrap-icons/font/bootstrap-icons.css'

// Bootstrap JS
import * as bootstrap from 'bootstrap'
window.bootstrap = bootstrap

import App from './App.vue'
import router from './router'
import './assets/main.scss'

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(VueToast, {
  position: 'top-right',
  duration: 3000
})

app.mount('#app')