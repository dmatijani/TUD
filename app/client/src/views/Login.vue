<script setup>
import { ref } from "vue";
import { onMounted } from 'vue';
import { useRouter } from 'vue-router';
import RestServices from "../services/rest.mjs";
import AuthController from "../services/authController.mjs";
import ErrorMessage from "../components/ErrorMessage.vue";

const authController = new AuthController();
const router = useRouter();

const errorMessage = ref("");

onMounted(() => {
  if (authController.isAuthenticated()) {
    router.push({ name: 'pocetna' })
  }
});

const username = ref("");
const password = ref("");

const submitForm = async () => {
    const rest = new RestServices("http://localhost:12345/api");
    const response = await rest.sendRequest("POST", "/user/login", {
        username: username.value,
        password: password.value,
    });

    if (response.success) {
        authController.saveLoggedInUser(response.user);
        router.go(0);
        router.push({ name: 'pocetna' })
    } else {
        errorMessage.value = response.error;
    }
};

// TODO: maknuti sve ove druge metode i gumbove (ovo je za probu, vidi samo gdje staviti odjavu)
const getJwt = async () => {
    const rest = new RestServices("http://localhost:12345/api");
    const response = await rest.sendRequest("GET", "/user/jwt");
    console.log("Odgovor sa servera: ", response);
}

const logout = async () => {
    const rest = new RestServices("http://localhost:12345/api");
    const response = await rest.sendRequest("GET", "/user/logout");
    
    if (response.success) {
        authController.removeLoggedInUser();
    }
}

const loggedInOnly = async () => {
    const rest = new RestServices("http://localhost:12345/api");
    const response = await rest.sendRequest("GET", "/user/loggedInOnly", undefined, true);
    console.log("Odgovor sa servera: ", response);
}
</script>

<template>
    <h2>Prijava</h2>
    <form id="signin_form" @submit.prevent="submitForm">
        <fieldset>
            <label for="username">
                Korisničko ime
            </label>
            <input type="text" id="username" v-model="username" placeholder="Korisničko ime" required />
            <label for="password">
                Lozinka
            </label>
            <input type="password" id="password" v-model="password" placeholder="Lozinka" required />
            <button type="submit">Prijavi</button>
        </fieldset>
    </form>
    <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>

    <button @click="getJwt">Dobij JWT</button>
    <button @click="logout">Odjava</button>
    <button @click="loggedInOnly">Zaštićen resurs</button>
</template>