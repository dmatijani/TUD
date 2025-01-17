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

const navigate = (name) => {
    router.push({ name: name });
}

const goBack = () => {
    router.go(-1);
}
</script>

<template>
    <ul>
        <Authenticated>
            <li v-on:click="goBack"><img src="@/assets/arrow_back.svg" alt="Natrag"></li>
        </Authenticated>
        <li v-on:click="navigate('pocetna')">Početna</li>
        <li v-on:click="navigate('registracija')">Registracija</li>
        <NotAuthenticated>
            <li v-on:click="navigate('prijava')">Prijava</li>
        </NotAuthenticated>
        <Authenticated>
            <li v-on:click="navigate('dokumenti')">Dokumenti</li>
            <li v-on:click="navigate('profil')">Profil</li>
            <li v-on:click="logout()">Odjava</li>
        </Authenticated>
    </ul>
</template>

<style scoped>
ul {
    list-style-type: none;
    width: var(--nav-width);
    position: fixed;
    overflow: hidden;
}

ul li {
    padding: var(--main-padding);
    border-right: var(--border);
    border-bottom: var(--border);
}

ul li:hover {
    background-color: var(--main-color);
}
</style>