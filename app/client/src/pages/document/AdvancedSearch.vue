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

const addNewGroup = () => {
    sharedWithGroups.value.push(null);
}

const removeGroup = (index) => {
    sharedWithGroups.value.splice(index, 1);
}

const addNewUser = () => {
    sharedWithUsers.value.push(null);
}

const removeUser = (index) => {
    sharedWithUsers.value.splice(index, 1);
}

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
    errorMessage.value = "";

    const response = await rest.sendRequest("POST", "/document/advancedSearch", {
        namePart: namePart.value,
        documentType: documentType.value,
        minNumberOfVersions: minNumberOfVersions.value,
        maxNumberOfVersions: maxNumberOfVersions.value,
        minCreatedDate: minCreatedDate.value,
        maxCreatedDate: maxCreatedDate.value,
        minLastModifiedDate: minLastModifiedDate.value,
        maxLastModifiedDate: maxLastModifiedDate.value,
        hasFinal: hasFinal.value,
        created: created.value,
        sharedWithGroups: sharedWithGroups.value,
        sharedWithUsers: sharedWithUsers.value
    }, true);

    if (response.success) {
        console.log(response);
        // TODO: prebaciti ovo nekako u DocumentList
    } else {
        errorMessage.value = response.error;
    }
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
            <hr />
            <h3>Dijeljeno s grupama</h3>
            <div v-for="(groupValue, groupIndex) in sharedWithGroups">
                <select v-model="sharedWithGroups[groupIndex]">
                    <option :value="group.id" v-for="group in groups
                        .filter((g) => !sharedWithGroups.includes(g.id) || g.id == groupValue)">{{ group.naziv }}</option>
                </select>
                <input type="button" v-on:click="removeGroup(groupIndex)" value="-">
            </div>
            <input type="button" v-if="sharedWithGroups.length < groups.length" v-on:click="addNewGroup" value="+">
            <hr />
            <h3>Dijeljeno s korisnicima</h3>
            <div v-for="(userValue, userIndex) in sharedWithUsers">
                <select v-model="sharedWithUsers[userIndex]">
                    <option :value="user.id" v-for="user in users
                        .filter((u) => !sharedWithUsers.includes(u.id) || u.id == userValue)">{{ user.naziv }}</option>
                </select>
                <input type="button" v-on:click="removeUser(userIndex)" value="-">
            </div>
            <input type="button" v-if="sharedWithUsers.length < users.length" v-on:click="addNewUser" value="+">
            <hr />
            <input type="button" value="Očisti filtere" v-on:click="clearResults">
            <input type="button" value="Očisti rezultate"> <!-- TODO -->
            <button type="submit">Pretraži</button>
        </fieldset>
    </form>
    <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
    <!-- TODO: lista pronađenih dokumenata -->
</template>