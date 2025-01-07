<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from 'vue-router';
import RestServices from "../services/rest.mjs";
import AuthController from "../services/authController.mjs";
import ErrorMessage from "../components/ErrorMessage.vue";

const authController = new AuthController();
const router = useRouter();
const rest = new RestServices();

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
    <div v-if="userData != null">
        <h3>Osnovno</h3>
        <ul>
            <li>Ime: <span>{{ userData.ime }}</span></li>
            <li>Prezime: <span>{{ userData.prezime }}</span></li>
            <li>Korisničko ime: <span>{{ userData.korime }}</span></li>
            <li>Email: <span>{{ userData.email }}</span></li>
            <li>Adresa: <span>{{ userData.adresa }}</span></li>
            <li>Telefon: <span>{{ userData.telefon }}</span></li>
            <li>Vrijeme registracije: <span>{{ userData.vrijeme_registracije }}</span></li>
        </ul>
    </div>
    <div v-if="userData != null">
        <h3>Grupe</h3>
        <ul>
            <li v-for="grupa in userData.grupe"><ul>
                <li>Naziv: <span>{{ grupa.naziv }}</span></li>
                <li>Vrijeme učlanjivanja: <span>{{ grupa.vrijeme_uclanjivanja }}</span></li>
                <li v-if="grupa.je_vlasnik">Vlasnik</li>
                <li><RouterLink :to="'/group/' + grupa.grupa_id">Detalji grupe</RouterLink></li>
            </ul></li>
        </ul>
        <RouterLink to="/group/create">Kreiraj novu grupu</RouterLink>
    </div>
    <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
</template>