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
<RouterLink to="/">Home</RouterLink>
<NotAuthenticated>
    <RouterLink to="/login">Prijava</RouterLink>
</NotAuthenticated>
<Authenticated>
    <p>Prijavljen: {{ loggedInUserName() }}</p>
    <button @click="logout">Odjava</button>
</Authenticated>
</template>