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

var docTypes = [
    "Tip 1",
    "Tip 2",
    "Tip 3"
]

const name = ref("");
const description = ref("");
const documentType = ref("");
const final = ref(false);
const note = ref("");
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
    formData.append("description", description.value);
    formData.append("documentType", documentType.value);
    formData.append("final", final.value);
    formData.append("note", note.value);
    formData.append("file", file.value);

    const rest = new RestServices();
    const response = await rest.sendRequest("POST", "/document/create", formData, false, "multipart/form-data");

    if (response.success) {
        successMessage.value = response.text;
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
            <label for="description">
                Opis dokumenta
            </label>
            <textarea id="description" v-model="description" placeholder="Opis" rows="5"></textarea>
            <label for="documentType">
                Vrsta dokumenta
            </label>
            <select name="documentType" id="documentType" v-model="documentType">
                <option v-for="docType in docTypes" :value="docType">{{ docType }}</option>
            </select>
            <hr />
            <label for="note">
                Bilješka uz prvu verziju
            </label>
            <textarea id="note" v-model="note" placeholder="Bilješka uz prvu verziju" rows="3"></textarea>
            <label for="final">
                Finalna?
            </label>
            <input type="checkbox" id="final" name="final" v-model="final" />
            <label for="file">
                Datoteka
            </label>
            <input type="file" id="file" @change="handleFileChanged" placeholder="Početna datoteka" required />
            <button type="submit">Prenesi prvu verziju dokumenta</button>
        </fieldset>
    </form>
    <SuccessMessage v-if="successMessage != null && successMessage != ''">
        <span>{{ successMessage }}</span>
        <RouterLink to="/login">Odi na prijavu</RouterLink> <!-- TODO: odi na novokreirani dokument -->
    </SuccessMessage>
    <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
</template>