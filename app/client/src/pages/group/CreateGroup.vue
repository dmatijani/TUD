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
    <div class="content">
        <form @submit.prevent="submitForm">
            <table>
                <tr>
                    <td>
                        <label for="name">
                            Naziv grupe
                        </label>
                    </td>
                    <td colspan="3">
                        <input type="text" id="name" v-model="name" placeholder="Naziv grupe" required />
                    </td>
                    <td></td>
                </tr>
                <tr class="form-space"></tr>
                <tr>
                    <td colspan="2"></td>
                    <td class="form-center">
                        <button type="submit">Kreiraj grupu</button>
                    </td>
                    <td colspan="2"></td>
                </tr>
                <tr>
                    <td colspan="5" class="form-center">
                        <SuccessMessage v-if="successMessage != null && successMessage != ''">
                            <span>{{ successMessage }}</span>
                            <RouterLink v-if="newGroupId != null" :to="'/group/' + newGroupId">Odi na novokreiranu grupu</RouterLink>
                        </SuccessMessage>
                        <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
                    </td>
                </tr>
            </table>
        </form>
    </div>
</template>