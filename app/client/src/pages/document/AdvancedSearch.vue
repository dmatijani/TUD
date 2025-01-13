<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from 'vue-router';
import AuthController from "../../services/authController.mjs";
import RestServices from "../../services/rest.mjs";
import ErrorMessage from "../../components/ErrorMessage.vue";

const authController = new AuthController();
const rest = new RestServices();
const router = useRouter();

const errorMessage = ref("");

const docTypes = ref([]);
const groups = ref([]);
const users = ref([]);

const namePart = ref(null);
const documentType = ref(null);
const minNumberOfVersions = ref(null);
const maxNumberOfVersions = ref(null);
const minCreatedDate = ref(null);
const maxCreatedDate = ref(null);
const minLastModifiedDate = ref(null);
const maxLastModifiedDate = ref(null);
const hasFinal = ref(null);
const created = ref(null);
const sharedWithGroups = ref([]);
const sharedWithUsers = ref([]);

const clearResults = () => {
    namePart.value = null;
    documentType.value = null;
    minNumberOfVersions.value = null;
    maxNumberOfVersions.value = null;
    minCreatedDate.value = null;
    maxCreatedDate.value = null;
    minLastModifiedDate.value = null;
    maxLastModifiedDate.value = null;
    hasFinal.value = null;
    created.value = null;
    sharedWithGroups.value = [];
    sharedWithUsers.value = [];
}

const loadTypes = async() => {
    const getTypesResponse = await rest.sendRequest("GET", "/types");

    if (getTypesResponse.success) {
        docTypes.value = getTypesResponse.types;
    }
}

const loadGroups = async () => {
    const response = await rest.sendRequest("GET", "/groups/all", null, true);

    if (response.success) {
        groups.value = response.groups;
    };
}

const loadUsers = async () => {
    const response = await rest.sendRequest("GET", "/users/all", null, true);

    if (response.success) {
        users.value = response.users;
    };
}

onMounted(async () => {
    if (!authController.isAuthenticated()) {
        router.push({ name: 'prijava' });
        return;
    }

    await loadTypes();
    await loadGroups();
    await loadUsers();
});

const submitForm = async () => {
    successMessage.value = "";
    errorMessage.value = "";

    // const response = await rest.sendRequest("POST", "/document/create", formData, true, "multipart/form-data");

    // if (response.success) {
    //     newDocumentId.value = response.newDocumentId;
    //     successMessage.value = response.text;
    // } else {
    //     errorMessage.value = response.error;
    // }
};
</script>

<template>
    <h2>Napredno pretraživanje dokumenata</h2>
    <form @submit.prevent="submitForm">
        <fieldset>
            <label for="namePart">
                Dio naziva
            </label>
            <input type="text" id="namePart" v-model="namePart" placeholder="Sadrži u nazivu" />
            <label for="documentType">
                Vrsta dokumenta
            </label>
            <select name="documentType" id="documentType" v-model="documentType">
                <option v-for="docType in docTypes" :value="docType">{{ docType }}</option>
            </select>
            <label for="minNumberOfVersions">
                Najmanji broj verzija
            </label>
            <input type="number" name="minNumberOfVersions" id="minNumberOfVersions" v-model="minNumberOfVersions" min="1">
            <label for="maxNumberOfVersions">
                Najveći broj verzija
            </label>
            <input type="number" name="maxNumberOfVersions" id="maxNumberOfVersions" v-model="maxNumberOfVersions" min="1">
            <label for="minCreatedDate">
                Kreirano najranije
            </label>
            <input type="datetime-local" name="minCreatedDate" id="minCreatedDate" v-model="minCreatedDate" >
            <label for="maxCreatedDate">
                Kreirano najkasnije
            </label>
            <input type="datetime-local" name="maxCreatedDate" id="maxCreatedDate" v-model="maxCreatedDate" >
            <label for="minLastModifiedDate">
                Zadnja izmjena najranije
            </label>
            <input type="datetime-local" name="minLastModifiedDate" id="minLastModifiedDate" v-model="minLastModifiedDate" >
            <label for="maxLastModifiedDate">
                Zadnja izmjena najkasnije
            </label>
            <input type="datetime-local" name="maxLastModifiedDate" id="maxLastModifiedDate" v-model="maxLastModifiedDate" >
            <label for="hasFinal">
                Ima finalnu?
            </label>
            <select name="hasFinal" id="hasFinal" v-model="hasFinal">
                <option :value="true">Samo koji ima finalnu verziju</option>
                <option :value="false">Samo koji nema finalnu verziju</option>
            </select>
            <label for="created">
                Stvorio dokument
            </label>
            <select name="created" id="created" v-model="created">
                <option v-for="user in users" :value="user.id">{{ user.naziv }}</option>
            </select>
            <!-- const sharedWithGroups = ref([]); -->
            <!-- const sharedWithUsers = ref([]); -->
            <input type="button" value="Očisti filtere" v-on:click="clearResults"> <!-- TODO -->
            <hr />
            <input type="button" value="Očisti rezultate"> <!-- TODO -->
            <button type="submit">Pretraži</button>
        </fieldset>
    </form>
    <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
    <h2></h2>
</template>