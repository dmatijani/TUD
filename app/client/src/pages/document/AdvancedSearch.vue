<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from 'vue-router';
import AuthController from "../../services/authController.mjs";
import RestServices from "../../services/rest.mjs";
import SuccessMessage from "../../components/SuccessMessage.vue";
import ErrorMessage from "../../components/ErrorMessage.vue";

const authController = new AuthController();
const rest = new RestServices();
const router = useRouter();

const successMessage = ref("");
const errorMessage = ref("");

const groups = ref([]);
const users = ref([]);

const loadGroups = async () => {
    const response = await rest.sendRequest("GET", "/groups/all", null, true);

    if (response.success) {
        console.log(response.groups);
    };
}

const loadUsers = async () => {
    const response = await rest.sendRequest("GET", "/users/all", null, true);

    if (response.success) {
        console.log(response.users);
    };
}

onMounted(async () => {
    if (!authController.isAuthenticated()) {
        router.push({ name: 'prijava' });
        return;
    }

    await loadGroups();
    await loadUsers();
});
</script>

<template>
    <h2>Napredno pretraživanje dokumenata</h2>
</template>