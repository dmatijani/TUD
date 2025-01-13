<script setup>
import { ref, onMounted } from "vue";
import RestServices from "../../services/rest.mjs";
import ErrorMessage from "../../components/ErrorMessage.vue";

const rest = new RestServices();

const loading = ref(false);
const errorMessage = ref("");
const documentData = ref(null);

const props = defineProps(["path", "method", "loadOnMounted"]);

var path = "";
var method = "GET";

const clear = () => {
    errorMessage.value = "";
    documentData.value = null;
}

const loadDocumentData = async (params = null) => {
    clear();
    loading.value = true;
    const response = await rest.sendRequest(method, `/documents/${path}`, params, true);
    loading.value = false;

    if (response.success) {
        documentData.value = response.documents;
    } else {
        errorMessage.value = response.error;
    }
}

defineExpose({
    clear,
    loadDocumentData
});

onMounted(async () => {
    path = props.path;
    if (props.method != undefined && props.method != null) {
        method = props.method;
    }

    if (props.loadOnMounted == undefined || props.loadOnMounted == null || props.loadOnMounted == true) {
        await loadDocumentData();
    }
});
</script>

<template>
    <p v-if="loading">Učitavam...</p>
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