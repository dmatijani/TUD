<script setup>
import { onMounted } from "vue";
import { useRouter } from 'vue-router';
import AuthController from "../../services/authController.mjs";
import DocumentList from "./DocumentList.vue";

const authController = new AuthController();
const router = useRouter();

onMounted(async () => {
    if (!authController.isAuthenticated()) {
        router.push({ name: 'prijava' });
        return;
    }
});
</script>

<template>
    <h2>Moji dokumenti</h2>
    <RouterLink to="/documents/create">Stvori novi dokument</RouterLink>
    <DocumentList role="vlasnik" />
</template>