<script setup>
import { ref } from "vue";
import RestServices from "../services/rest.mjs";
import SuccessMessage from "../components/SuccessMessage.vue";
import ErrorMessage from "../components/ErrorMessage.vue";

const successMessage = ref("");
const errorMessage = ref("");

const name = ref("");
const surname = ref("");
const email = ref("");
const username = ref("");
const password = ref("");
const address = ref("");
const phone = ref("");

const submitForm = async () => {
    successMessage.value = "";
    errorMessage.value = "";

    const rest = new RestServices();
    const response = await rest.sendRequest("POST", "/user/register", {
        name: name.value,
        surname: surname.value,
        email: email.value,
        username: username.value,
        password: password.value,
        address: address.value,
        phone: phone.value
    });

    if (response.success) {
        successMessage.value = response.text;
    } else {
        errorMessage.value = response.error;
    }
};
</script>

<template>
    <h2>Registracija</h2>
    <div class="content">
        <form @submit.prevent="submitForm">
            <table>
                <tr>
                    <td colspan="2">
                        <label for="name">
                            Ime i prezime
                        </label>
                    </td>
                    <td colspan="3">
                        <input type="text" id="name" v-model="name" placeholder="Ime" required />
                    </td>
                    <td colspan="3">
                        <input type="text" id="surname" v-model="surname" placeholder="Prezime" required />
                    </td>
                    <td colspan="2"></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label for="email">
                            Email
                        </label>
                    </td>
                    <td colspan="6">
                        <input type="email" id="email" v-model="email" placeholder="Email" required />
                    </td>
                    <td colspan="2"></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label for="username">
                            Korisničko ime
                        </label>
                    </td>
                    <td colspan="6">
                        <input type="text" id="username" v-model="username" placeholder="Korisničko ime" required />
                    </td>
                    <td colspan="2"></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label for="password">
                            Lozinka
                        </label>
                    </td>
                    <td colspan="6">
                        <input type="password" id="password" v-model="password" placeholder="Lozinka" required />
                    </td>
                    <td colspan="2"></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label for="address">
                            Adresa
                        </label>
                    </td>
                    <td colspan="6">
                        <input type="text" id="address" v-model="address" placeholder="Adresa (neobavezno)" />
                    </td>
                    <td colspan="2"></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label for="phone">
                            Telefon
                        </label>
                    </td>
                    <td colspan="6">
                        <input type="text" id="phone" v-model="phone" placeholder="Telefon (neobavezno)" />
                    </td>
                    <td colspan="2"></td>
                </tr>
                <tr class="form-space"></tr>
                <tr>
                    <td colspan="4"></td>
                    <td colspan="2" class="form-center">
                        <button type="submit">Registriraj se</button>
                    </td>
                    <td colspan="4"></td>
                </tr>
                <tr>
                    <td colspan="10" class="form-center">
                        <SuccessMessage v-if="successMessage != null && successMessage != ''">
                            <span>{{ successMessage }} </span>
                            <RouterLink to="/login">Odi na prijavu</RouterLink>
                        </SuccessMessage>
                        <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
                    </td>
                </tr>
            </table>
        </form>
    </div>
</template>