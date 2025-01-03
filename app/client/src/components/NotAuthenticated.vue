<script setup>
import { ref, onMounted } from "vue";
import AuthController from "../services/authController.mjs";

const isAuthenticated = ref(false);

onMounted(async () => {
    const authController = new AuthController();
    isAuthenticated.value = authController.isAuthenticated();
});
</script>

<template>
    <template v-if="!isAuthenticated">
        <slot></slot>
    </template>
</template>
