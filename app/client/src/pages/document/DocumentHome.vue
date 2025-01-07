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
    <RouterLink to="/documents/myDocuments">Moji dokumenti</RouterLink>
</template>