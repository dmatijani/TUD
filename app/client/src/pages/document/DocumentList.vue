<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from 'vue-router';
import RestServices from "../../services/rest.mjs";
import ErrorMessage from "../../components/ErrorMessage.vue";

const router = useRouter();

const rest = new RestServices();

const loading = ref(false);
const errorMessage = ref("");
const documentData = ref(null);

const props = defineProps(["path", "method", "loadOnMounted"]);

var path = "";
var method = "GET";

const navigate = (path) => {
    router.push(path);
}

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
    <div class="documentHolder" v-for="document of documentData" v-on:click="navigate('/document/' + document.id)">
        <ul>
            <li><h4>{{ document.naziv }}</h4></li>
            <li>Vrsta: {{ document.vrsta }}</li>
            <li>Broj verzija: {{ document.broj_verzija }}<span v-if="document.ima_finalnu"> - <span class="podebljano">ima finalnu</span></span></li>
            <li>Kreiran {{ (new Date(document.prva_izmjena)).toLocaleString() }} od <span class="izmijenio">{{ document.prvi_izmijenio }}</span></li>
            <li v-if="document.broj_verzija > 1">Zadnje izmijenjen {{ (new Date(document.zadnja_izmjena)).toLocaleString() }} od <span class="izmijenio">{{ document.zadnji_izmijenio }}</span></li>
        </ul>
    </div>
    <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
</template>

<style scoped>
.documentHolder {
    margin-bottom: var(--list-space);
}

.documentHolder:last-child {
    margin-bottom: 0px;
}

ul {
    list-style-type: none;
    padding: var(--main-padding);
    border: var(--border-width) solid var(--main-border-color);
    border-radius: var(--main-padding);
    background-color: var(--main-bg-color);
}

.izmijenio {
    font-style: italic;
}

.podebljano {
    font-weight: bold;
}
</style>