<script setup>
import { ref, onMounted } from "vue";
import { useRoute } from 'vue-router';
import { useRouter } from 'vue-router';
import RestServices from "../../services/rest.mjs";
import AuthController from "../../services/authController.mjs";
import SuccessMessage from "../../components/SuccessMessage.vue";
import ErrorMessage from "../../components/ErrorMessage.vue";

const authController = new AuthController();
const route = useRoute();
const router = useRouter();
const rest = new RestServices();

const documentId = route.params.id;

const successMessage = ref("");
const errorMessage = ref("");

const final = ref(false);
const note = ref("");
const file = ref(null);

onMounted(async () => {
    if (!documentId) {
        router.push({ name: 'prijava' });
        return;
    }

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
    formData.append("final", final.value);
    formData.append("note", note.value);
    formData.append("file", file.value);

    const response = await rest.sendRequest("POST", `/document/version/${documentId}`, formData, true, "multipart/form-data");

    if (response.success) {
        successMessage.value = response.text;
    } else {
        errorMessage.value = response.error;
    }
};
</script>

<template>
    <h2>Prenesi novu verziju dokumenta</h2>
    <form @submit.prevent="submitForm">
        <fieldset>
            <label for="note">
                Bilješka uz novu verziju
            </label>
            <textarea id="note" v-model="note" placeholder="Bilješka uz novu verziju" rows="3"></textarea>
            <label for="final">
                Finalna?
            </label>
            <input type="checkbox" id="final" name="final" v-model="final" />
            <label for="file">
                Datoteka
            </label>
            <input type="file" id="file" @change="handleFileChanged" placeholder="Početna datoteka" required />
            <button type="submit">Prenesi novu verziju dokumenta</button>
        </fieldset>
    </form>
    <SuccessMessage v-if="successMessage != null && successMessage != ''">
        <span>{{ successMessage }}</span>
        <RouterLink :to="'/document/' + documentId">Odi na dokument</RouterLink>
    </SuccessMessage>
    <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
</template>