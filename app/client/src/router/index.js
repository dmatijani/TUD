import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: '/',
            name: 'pocetna',
            component: HomeView
        },
        {
            path: '/login',
            name: 'prijava',
            component: () => import('../views/Login.vue')
        }
    ],
})

export default router
