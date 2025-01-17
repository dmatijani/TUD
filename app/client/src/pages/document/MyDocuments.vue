<script setup>
import { onMounted } from "vue";
import { useRouter } from 'vue-router';
import AuthController from "../../services/authController.mjs";
import DocumentList from "./DocumentList.vue";

const authController = new AuthController();
const router = useRouter();

const navigate = (path) => {
    router.push(path);
}

onMounted(async () => {
    if (!authController.isAuthenticated()) {
        router.push({ name: 'prijava' });
        return;
    }
});
</script>

<template>
    <h2>Moji dokumenti</h2>
    <div class="content">
        <button v-on:click="navigate('/documents/create')">Stvori novi dokument</button>
        <div style="height: var(--form-space);"></div>
        <DocumentList path="vlasnik" />
    </div>
</template>