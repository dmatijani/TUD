<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from 'vue-router';
import RestServices from "../services/rest.mjs";
import AuthController from "../services/authController.mjs";
import ErrorMessage from "../components/ErrorMessage.vue";

const authController = new AuthController();
const router = useRouter();
const rest = new RestServices();

const navigate = (path) => {
    router.push(path);
}

const errorMessage = ref("");
const userData = ref(null);

onMounted(async () => {
    if (!authController.isAuthenticated()) {
        router.push({ name: 'prijava' });
        return;
    }

    const response = await rest.sendRequest("GET", "/user/profile", null, true);
    if (response.success) {
        userData.value = response.user;
    } else {
        errorMessage.value = response.error;
    }
});
</script>

<template>
    <h2>Profil</h2>
    <div class="content">
        <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
        <div class="section" v-if="userData != null">
            <h3>Osnovno</h3>
            <ul>
                <li>Ime i prezime: <span>{{ userData.ime }} {{ userData.prezime }}</span></li>
                <li>Korisničko ime: <span>{{ userData.korime }}</span></li>
                <li>Email: <span>{{ userData.email }}</span></li>
                <li>Adresa: <span>{{ userData.adresa }}</span></li>
                <li>Telefon: <span>{{ userData.telefon }}</span></li>
                <li>Vrijeme registracije: <span>{{ (new Date(userData.vrijeme_registracije)).toLocaleString() }}</span></li>
            </ul>
        </div>
        <div style="height: var(--form-space);"></div>
        <div class="section" v-if="userData != null">
            <h3>Grupe</h3>
            <button v-on:click="navigate('/group/create')">Kreiraj novu grupu</button>
            <div class="padding group" v-for="grupa in userData.grupe" v-on:click="navigate('/group/' + grupa.grupa_id)">
                <ul>
                    <li><h4>{{ grupa.naziv }} <span v-if="grupa.je_vlasnik"> (vaša grupa)</span></h4></li>
                    <li>Član ste od <span>{{ (new Date(grupa.vrijeme_uclanjivanja)).toLocaleString() }}</span></li>
                </ul>
            </div>
        </div>
    </div>
</template>

<style scoped>
ul {
    list-style-type: none;
}

.padding {
    padding: var(--main-padding);
}

.group {
    width: 40%;
    min-width: 200px;
    padding: var(--main-padding);
    border: var(--border-width) solid var(--main-border-color);
    border-radius: var(--main-padding);
    background-color: var(--main-bg-color);
    margin-top: var(--form-space);
}

.group:hover {
    background-color: var(--main-color);
    border: var(--border-width) solid var(--link-hover-color);
}

.group:hover:active {
    background-color: var(--main-border-color);
    border: var(--border-width) solid var(--link-hover-color);
}
</style>