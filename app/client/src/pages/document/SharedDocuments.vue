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
    <h2>Dokumenti dijeljeni sa mnom</h2>
    <DocumentList path="čitanje" />
</template>