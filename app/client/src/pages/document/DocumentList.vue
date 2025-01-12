<script setup>
import { ref, onMounted } from "vue";
import RestServices from "../../services/rest.mjs";
import ErrorMessage from "../../components/ErrorMessage.vue";

const rest = new RestServices();

const errorMessage = ref("");
const documentData = ref(null);

const props = defineProps(["role"]);

var role = "";

const loadDocumentData = async () => {
    const response = await rest.sendRequest("GET", `/documents/${role}`, null, true);

    if (response.success) {
        documentData.value = response.documents;
    } else {
        errorMessage.value = response.error;
    }
}

onMounted(async () => {
    role = props.role;

    await loadDocumentData();
});
</script>

<template>
    <ul>
        <li v-for="document of documentData">
            <ul>
                <li>Naziv: {{ document.naziv }}</li>
                <li>Vrsta: {{ document.vrsta }}</li>
                <li>Broj verzija: {{ document.broj_verzija }}</li>
                <li>Prva izmjena: {{ document.prva_izmjena }}</li>
                <li>Kreirao: {{ document.prvi_izmijenio }}</li>
                <li v-if="document.broj_verzija > 1">Zadnja izmjena: {{ document.zadnja_izmjena }}</li>
                <li v-if="document.broj_verzija > 1">Zadnji izmijenio: {{ document.zadnji_izmijenio }}</li>
                <li v-if="document.ima_finalnu">Ima finalnu verziju</li>
                <li><RouterLink :to="'/document/' + document.id">Detalji dokumenta</RouterLink></li>
            </ul>
        </li>
    </ul>
    <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
</template>