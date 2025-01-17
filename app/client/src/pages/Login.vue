<script setup>
import { ref } from "vue";
import { onMounted } from 'vue';
import { useRouter } from 'vue-router';
import RestServices from "../services/rest.mjs";
import AuthController from "../services/authController.mjs";
import ErrorMessage from "../components/ErrorMessage.vue";

const authController = new AuthController();
const router = useRouter();

const errorMessage = ref("");

onMounted(() => {
    if (authController.isAuthenticated()) {
        router.push({ name: 'pocetna' });
    }
});

const username = ref("");
const password = ref("");

const submitForm = async () => {
    const rest = new RestServices();
    const response = await rest.sendRequest("POST", "/user/login", {
        username: username.value,
        password: password.value,
    });

    if (response.success) {
        authController.saveLoggedInUser(response.user);
        router.go(0);
        router.push({ name: 'pocetna' })
    } else {
        errorMessage.value = response.error;
    }
};
</script>

<template>
    <h2>Prijava</h2>
    <div class="content">
        <form @submit.prevent="submitForm">
            <table>
                <tr>
                    <td>
                        <label for="username">
                            Korisničko ime
                        </label>
                    </td>
                    <td colspan="3">
                        <input type="text" id="username" v-model="username" placeholder="Korisničko ime" required />
                    </td>
                    <td></td>
                </tr>
                <tr>
                    <td>
                        <label for="password">
                            Lozinka
                        </label>
                    </td>
                    <td colspan="3">
                        <input type="password" id="password" v-model="password" placeholder="Lozinka" required />
                    </td>
                    <td></td>
                </tr>
                <tr class="form-space"></tr>
                <tr>
                    <td colspan="2"></td>
                    <td class="form-center">
                        <button type="submit">Prijavi</button>
                    </td>
                    <td colspan="2"></td>
                </tr>
                <tr>
                    <td colspan="5" class="form-center">
                        <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
                    </td>
                </tr>
            </table>
        </form>
    </div>
</template>

<style scoped>
.content {
    max-height: 800px;
    display: flex;
    align-items: center;
}
</style>