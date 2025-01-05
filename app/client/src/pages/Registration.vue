<script setup>
import { ref } from "vue";
import { useRouter } from 'vue-router';
import RestServices from "../services/rest.mjs";
import SuccessMessage from "../components/SuccessMessage.vue";
import ErrorMessage from "../components/ErrorMessage.vue";

const successMessage = ref("");
const errorMessage = ref("");

const name = ref("");
const surname = ref("");
const email = ref("");
const username = ref("");
const password = ref("");

const submitForm = async () => {
    const rest = new RestServices();
    const response = await rest.sendRequest("POST", "/user/register", {
        name: name.value,
        surname: surname.value,
        email: email.value,
        username: username.value,
        password: password.value,
    });

    if (response.success) {
        errorMessage.value = "";
        successMessage.value = "Uspješno ste registrirali novog korisnika!";
    } else {
        successMessage.value = "";
        errorMessage.value = response.error;
    }
};
</script>

<template>
    <h2>Registracija</h2>
    <form @submit.prevent="submitForm">
        <fieldset>
            <label for="name">
                Ime
            </label>
            <input type="text" id="name" v-model="name" placeholder="Ime" required />
            <label for="surname">
                Prezime
            </label>
            <input type="text" id="surname" v-model="surname" placeholder="Prezime" required />
            <label for="email">
                Email
            </label>
            <input type="email" id="email" v-model="email" placeholder="Email" required />
            <label for="username">
                Korisničko ime
            </label>
            <input type="text" id="username" v-model="username" placeholder="Korisničko ime" required />
            <label for="password">
                Lozinka
            </label>
            <input type="password" id="password" v-model="password" placeholder="Lozinka" required />
            <button type="submit">Registriraj se</button>
        </fieldset>
    </form>
    <SuccessMessage v-if="successMessage != null && successMessage != ''">
        <span>{{ successMessage }}</span>
        <RouterLink to="/login">Odi na prijavu</RouterLink>
    </SuccessMessage>
    <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
</template>