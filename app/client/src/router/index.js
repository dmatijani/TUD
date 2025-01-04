import { createRouter, createWebHistory } from 'vue-router'
import Home from '../pages/Home.vue';
import Login from '../pages/Login.vue';
import Registration from '../pages/Registration.vue';

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: '/',
            name: 'pocetna',
            component: Home
        },
        {
            path: '/login',
            name: 'prijava',
            component: Login
        },
        {
            path: '/register',
            name: 'registracija',
            component: Registration
        }
    ],
})

export default router
