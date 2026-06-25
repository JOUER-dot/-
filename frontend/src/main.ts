import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import './styles/tokens.css'
import './styles/theme.css'
import './styles/app.css'

import App from './App.vue'
import router from './router'
import { onAuthEvent } from '@/utils/auth-events'
import { useUserStore } from '@/stores/user'

const app = createApp(App)

const pinia = createPinia()
app.use(pinia)
app.use(router)
app.use(ElementPlus)

onAuthEvent('logout', async () => {
  const userStore = useUserStore(pinia)
  await userStore.logout(false)
  await router.replace('/login')
})

app.mount('#app')
