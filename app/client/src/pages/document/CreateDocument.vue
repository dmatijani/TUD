<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from 'vue-router';
import AuthController from "../../services/authController.mjs";
import RestServices from "../../services/rest.mjs";
import SuccessMessage from "../../components/SuccessMessage.vue";
import ErrorMessage from "../../components/ErrorMessage.vue";

const authController = new AuthController();
const router = useRouter();

const successMessage = ref("");
const errorMessage = ref("");

const name = ref("");
const file = ref(null);

onMounted(async () => {
    if (!authController.isAuthenticated()) {
        router.push({ name: 'prijava' });
        return;
    }
});

const handleFileChanged = (event) => {
    file.value = event.target.files[0];
}

const submitForm = async () => {
    successMessage.value = "";
    errorMessage.value = "";

    if (!file.value) {
        errorMessage.value = "Molimo odaberite datoteku!";
        return;
    }

    
    const formData = new FormData();
    formData.append("name", name.value);
    formData.append("file", file.value);
    // TODO: popisati ostale zapise i stvari

    console.log(formData);

    const rest = new RestServices();
    const response = await rest.sendRequest("POST", "/document/create", formData, true, "multipart/form-data");

    if (response.success) {
        successMessage.value = response.text;
        name.value = "";
        file.value = null;
    } else {
        errorMessage.value = response.error;
    }
};
</script>

<template>
    <h2>Kreiraj dokument</h2>
    <form @submit.prevent="submitForm">
        <fieldset>
            <label for="name">
                Naziv dokumenta
            </label>
            <input type="text" id="name" v-model="name" placeholder="Naziv dokumenta" required />
            <input type="file" id="file" @change="handleFileChanged" placeholder="Početna datoteka" required />
            <!-- TODO: dodati sva ostala polja potrebna -->
            <button type="submit">Prenesi prvu verziju dokumenta</button>
        </fieldset>
    </form>
    <SuccessMessage v-if="successMessage != null && successMessage != ''">
        <span>{{ successMessage }}</span>
        <RouterLink to="/login">Odi na prijavu</RouterLink> <!-- TODO: odi na novokreirani dokument -->
    </SuccessMessage>
    <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
</template>