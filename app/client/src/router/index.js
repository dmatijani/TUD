import { createRouter, createWebHistory } from 'vue-router'
import Home from '../pages/Home.vue';
import Login from '../pages/Login.vue';
import Registration from '../pages/Registration.vue';
import Profile from '../pages/Profile.vue';
import GroupDetails from '../pages/group/GroupDetails.vue';
import CreateGroup from '../pages/group/CreateGroup.vue';
import DocumentHome from '../pages/document/DocumentHome.vue';
import MyDocuments from '../pages/document/MyDocuments.vue';
import CreateDocument from '../pages/document/CreateDocument.vue';
import SharedDocuments from '../pages/document/SharedDocuments.vue';
import DocumentDetails from '../pages/document/DocumentDetails.vue';
import NewVersion from '../pages/document/NewVersion.vue';
import AdvancedSearch from '../pages/document/AdvancedSearch.vue';

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
        },
        {
            path: '/profile',
            name: 'profil',
            component: Profile
        },
        {
            path: '/group/:id',
            name: 'grupa',
            component: GroupDetails
        },
        {
            path: '/group/create',
            name: 'kreirajGrupu',
            component: CreateGroup
        },
        {
            path: '/documents',
            name: 'dokumenti',
            component: DocumentHome
        },
        {
            path: '/documents/myDocuments',
            name: 'mojiDokumenti',
            component: MyDocuments
        },
        {
            path: '/documents/sharedDocuments',
            name: 'dokumentiDijeljeniSaMnom',
            component: SharedDocuments
        },
        {
            path: '/documents/create',
            name: 'kreirajDokument',
            component: CreateDocument
        },
        {
            path: '/document/:id',
            name: 'detaljiDokumenta',
            component: DocumentDetails
        },
        {
            path: '/documents/newVersion/:id',
            name: 'novaVerzijaDokumenta',
            component: NewVersion
        },
        {
            path: '/documents/advancedSearch',
            name: 'naprednoPretrazivanje',
            component: AdvancedSearch
        }
    ],
})

export default router
