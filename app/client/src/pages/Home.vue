<script setup>
import { useRouter } from 'vue-router';
import Authenticated from "../components/Authenticated.vue";
import NotAuthenticated from "../components/NotAuthenticated.vue";

const router = useRouter();

const navigate = (path) => {
    router.push(path);
}
</script>

<template>
    <h2>Dobrodošli u TUD!</h2>
    <div class="content">
        <table>
            <tr>
                <td class="form-center">
                    <Authenticated>
                        <button v-on:click="navigate('/documents')">Dokumenti</button>
                        <div style="height: var(--form-space);"></div>
                        <button v-on:click="navigate('/profile')">Profil</button>
                        <div style="height: var(--form-space);"></div>
                    </Authenticated>
                    <NotAuthenticated>
                        <button v-on:click="navigate('/login')">Prijava</button>
                        <div style="height: var(--form-space);"></div>
                        <button v-on:click="navigate('/register')">Registracija</button>
                        <div style="height: var(--form-space);"></div>
                    </NotAuthenticated>
                </td>
            </tr>
        </table>
    </div>
</template>

<style scoped>
table {
    width: 100%;
}

button {
    width: 35%;
    min-width: 200px;
}
</style>