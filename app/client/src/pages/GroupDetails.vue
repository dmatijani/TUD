<script setup>
import { ref } from "vue";
import { onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { useRouter } from 'vue-router';
import RestServices from "../services/rest.mjs";
import AuthController from "../services/authController.mjs";
import ErrorMessage from "../components/ErrorMessage.vue";

const authController = new AuthController();
const route = useRoute();
const router = useRouter();
const rest = new RestServices();

const groupId = route.params.id;

const errorMessage = ref("");
const groupData = ref(null);

onMounted(async () => {
    if (!groupId) {
        router.push({ name: 'prijava' });
        return;
    }

    if (!authController.isAuthenticated()) {
        router.push({ name: 'prijava' });
        return;
    }

    const response = await rest.sendRequest("GET", `/group/${groupId}`, null, true);
    if (response.success) {
        groupData.value = response.group;
    } else {
        errorMessage.value = response.error;
    }
});
</script>

<template>
    <h2>Grupa <span v-if="groupData">{{ groupData.naziv }}</span></h2>
    <div v-if="groupData != null">
        <h3>Osnovno</h3>
        <li>Naziv: <span>{{ groupData.naziv }}</span></li>
        <li v-if="groupData.vlasnik.trim() != ''">Vlasnik: <span>{{ groupData.vlasnik }}</span></li>
        <li v-if="groupData.email_vlasnika != null">Email vlasnika: <span>{{ groupData.email_vlasnika }}</span></li>
    </div>
    <div v-if="groupData != null">
        <h3>Članovi</h3>
        <ul>
            <li v-for="clan in groupData.clanovi"><ul>
                <li>Ime i prezime: <span>{{ clan.korisnik }}</span></li>
                <li>Vrijeme učlanjivanja: <span>{{ clan.vrijeme_uclanjivanja }}</span></li>
                <li v-if="clan.je_vlasnik">Vlasnik</li>
            </ul></li>
        </ul>
    </div>
    <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
</template>
