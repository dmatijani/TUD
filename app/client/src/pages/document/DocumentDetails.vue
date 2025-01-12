<script setup>
import { ref, onMounted } from "vue";
import { useRoute } from 'vue-router';
import { useRouter } from 'vue-router';
import RestServices from "../../services/rest.mjs";
import AuthController from "../../services/authController.mjs";
import ErrorMessage from "../../components/ErrorMessage.vue";

const authController = new AuthController();
const route = useRoute();
const router = useRouter();
const rest = new RestServices();

const documentId = route.params.id;

const errorMessage = ref("");
const documentData = ref(null);

const loadDocumentData = async () => {
    const response = await rest.sendRequest("GET", `/document/${documentId}`, null, true);

    if (response.success) {
        documentData.value = response.document;
    } else {
        errorMessage.value = response.error;
    }
}

onMounted(async () => {
    if (!documentId) {
        router.push({ name: 'prijava' });
        return;
    }

    if (!authController.isAuthenticated()) {
        router.push({ name: 'prijava' });
        return;
    }

    await loadDocumentData();
});
</script>

<template>
    <h2>Detalji dokumenta</h2>
    {{ documentData }}
    <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
</template>