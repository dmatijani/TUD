<script setup>
import { onMounted } from "vue";
import { useRouter } from 'vue-router';
import AuthController from "../../services/authController.mjs";

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
    <h2>Dokumenti</h2>
    <div class="content">
        <table>
            <tr>
                <td class="form-center">
                    <button v-on:click="navigate('/')">Natrag</button>
                    <div style="height: var(--form-space);"></div>
                    <button v-on:click="navigate('/documents/create')">Stvori novi dokument</button>
                    <div style="height: var(--form-space);"></div>
                    <button v-on:click="navigate('/documents/myDocuments')">Moji dokumenti</button>
                    <div style="height: var(--form-space);"></div>
                    <button v-on:click="navigate('/documents/sharedDocuments')">Dokumenti dijeljeni sa mnom</button>
                    <div style="height: var(--form-space);"></div>
                    <button v-on:click="navigate('/documents/advancedSearch')">Napredno pretraživanje</button>
                    <div style="height: var(--form-space);"></div>
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