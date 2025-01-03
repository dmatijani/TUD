<script setup>
import { ref } from "vue";
import RestServices from "../services/rest.mjs";

const username = ref("");
const password = ref("");

const submitForm = async () => {
    try {
        const rest = new RestServices("http://localhost:12345");
        console.log(username.value);
        console.log(password.value);
        const response = await rest.sendRequest("POST", "/api/user/login", {
            username: username.value,
            password: password.value,
        });

        console.log("Odgovor sa servera:", response);
        alert("Prijava uspješna!");
    } catch (error) {
        console.error("Pogreška prilikom prijave:", error);
        alert("Prijava nije uspjela. Provjerite podatke.");
    }
};
</script>

<template>
    <h2>Prijava</h2>
    <form id="signin_form" @submit.prevent="submitForm">
        <fieldset>
            <label for="username">
                Korisničko ime
            </label>
            <input type="text" id="username" v-model="username" placeholder="Korisničko ime" required />
            <label for="password">
                Lozinka
            </label>
            <input type="password" id="password" v-model="password" placeholder="Lozinka" required />
            <button type="submit">Prijavi</button>
        </fieldset>
    </form>
</template>