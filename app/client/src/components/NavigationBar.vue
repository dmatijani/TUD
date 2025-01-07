<script setup>
import { useRouter } from 'vue-router';
import Authenticated from "../components/Authenticated.vue";
import NotAuthenticated from "../components/NotAuthenticated.vue";
import RestServices from "../services/rest.mjs";
import AuthController from "../services/authController.mjs";

const router = useRouter();

const authController = new AuthController();

const logout = async () => {
    let rest = new RestServices("http://localhost:12345/api");
    let response = await rest.sendRequest("GET", "/user/logout");
    
    if (response.success) {
        authController.removeLoggedInUser();
        router.go(0);        
        router.push({ name: 'pocetna' })
    }
}

const loggedInUserName = () => {
    let user = authController.getLoggedInUser();
    return `${user.name} ${user.surname}`;
}
</script>

<template>
    <ul>
        <li><RouterLink to="/">Početna</RouterLink></li>
        <li><RouterLink to="/register">Registracija</RouterLink></li>
        <NotAuthenticated>
            <li><RouterLink to="/login">Prijava</RouterLink></li>
        </NotAuthenticated>
        <Authenticated>
            <li><RouterLink to="/documents">Dokumenti</RouterLink></li>
            <li><span>Prijavljen: {{ loggedInUserName() }}</span></li>
            <li><RouterLink to="/profile">Profil</RouterLink></li>
            <li><span v-on:click="logout()">Odjava</span></li>
        </Authenticated>
    </ul>
</template>