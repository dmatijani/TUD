<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from 'vue-router';
import RestServices from "../../services/rest.mjs";
import AuthController from "../../services/authController.mjs";
import SuccessMessage from "../../components/SuccessMessage.vue";
import ErrorMessage from "../../components/ErrorMessage.vue";

const authController = new AuthController();
const router = useRouter();

const successMessage = ref("");
const errorMessage = ref("");

const name = ref("");
const newGroupId = ref(null);

onMounted(() => {
    if (!authController.isAuthenticated()) {
        router.push({ name: 'pocetna' });
    }
});

const submitForm = async () => {
    successMessage.value = "";
    errorMessage.value = "";
    newGroupId.value = null;

    if (name.value == null || name.value == "") {
        errorMessage.value = "Morate unijeti ime!";
        return;
    }
    const rest = new RestServices();
    const response = await rest.sendRequest("POST", "/group/create", {
        groupName: name.value
    }, true);

    if (response.success) {
        successMessage.value = response.text;
        newGroupId.value = response.newGroupId;
        console.log(newGroupId.value);
    } else {
        errorMessage.value = response.error;
    }
}
</script>

<template>
    <h2>Kreiraj novu grupu</h2>
    <form @submit.prevent="submitForm">
        <label for="name">
            Naziv grupe
        </label>
        <input type="text" id="name" v-model="name" placeholder="Naziv grupe" required />
        <button type="submit">Kreiraj grupu</button>
    </form>
    <SuccessMessage v-if="successMessage != null && successMessage != ''">
        <span>{{ successMessage }}</span>
        <RouterLink v-if="newGroupId != null" :to="'/group/' + newGroupId">Odi na novokreiranu grupu</RouterLink>
    </SuccessMessage>
    <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
</template>