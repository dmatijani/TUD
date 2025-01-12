<script setup>
import { onMounted } from "vue";
import { useRouter } from 'vue-router';
import AuthController from "../../services/authController.mjs";

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
    <h2>Dokumenti</h2>
    <RouterLink to="/documents/create">Stvori novi dokument</RouterLink>
    <RouterLink to="/documents/myDocuments">Moji dokumenti</RouterLink>
    <RouterLink to="/documents/sharedDocuments">Dokumenti dijeljeni sa mnom</RouterLink>
</template>