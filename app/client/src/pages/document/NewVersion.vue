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
    <div class="content">
        <form @submit.prevent="submitForm">
            <table>
                <tr>
                    <td colspan="10" class="form-center">
                        <h3>Nova verzija</h3>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label for="note">
                            Bilješka uz novu verziju
                        </label>
                    </td>
                    <td colspan="6">
                        <input type="text" id="note" v-model="note" placeholder="Bilješka uz novu verziju">
                    </td>
                    <td colspan="2"></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label for="final">
                            Finalna?
                        </label>
                    </td>
                    <td colspan="1">
                        <input type="checkbox" id="final" name="final" v-model="final" />
                    </td>
                    <td colspan="7"></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label for="file">
                            Datoteka
                        </label>
                    </td>
                    <td colspan="6">
                        <input type="file" id="file" @change="handleFileChanged" placeholder="Početna datoteka" required />
                    </td>
                    <td colspan="2"></td>
                </tr>
                <tr class="form-space"></tr>
                <tr>
                    <td colspan="4"></td>
                    <td colspan="2" class="form-center">
                        <button type="submit">Prenesi novu verziju dokumenta</button>
                    </td>
                    <td colspan="4"></td>
                </tr>
                <tr>
                    <td colspan="10" class="form-center">
                        <SuccessMessage v-if="successMessage != null && successMessage != ''">
                            <span>{{ successMessage }} </span>
                            <RouterLink :to="'/document/' + documentId">Odi na dokument</RouterLink>
                        </SuccessMessage>
                        <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
                    </td>
                </tr>
            </table>
        </form>
    </div>
</template>