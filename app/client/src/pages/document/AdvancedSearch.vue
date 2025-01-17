<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from 'vue-router';
import AuthController from "../../services/authController.mjs";
import RestServices from "../../services/rest.mjs";
import ErrorMessage from "../../components/ErrorMessage.vue";
import DocumentList from "../document/DocumentList.vue";

const authController = new AuthController();
const rest = new RestServices();
const router = useRouter();

const errorMessage = ref("");

const docTypes = ref([]);
const groups = ref([]);
const users = ref([]);

const documentListComponent = ref(null);

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

const clearFilters = () => {
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

const clearResults = () => {
    documentListComponent.value.clear();
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
    let params = {
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
    };

    documentListComponent.value.loadDocumentData(params);
};
</script>

<template>
    <h2>Napredno pretraživanje dokumenata</h2>
    <div class="content">
        <form @submit.prevent="submitForm">
            <table>
                <tr>
                    <td colspan="6" class="form-center">
                        <h3>Parametri pretraživanja</h3>
                    </td>
                </tr>
                <tr>
                    <td colspan="3">
                        <label for="namePart">
                            Dio naziva
                        </label>
                        <input type="text" id="namePart" v-model="namePart" placeholder="Sadrži u nazivu" />
                    </td>
                    <td colspan="3">
                        <label for="documentType">
                            Vrsta dokumenta
                        </label>
                        <select name="documentType" id="documentType" v-model="documentType">
                            <option v-for="docType in docTypes" :value="docType">{{ docType }}</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td colspan="3">
                        <label for="minNumberOfVersions">
                            Najmanji broj verzija
                        </label>
                        <input type="number" name="minNumberOfVersions" id="minNumberOfVersions" v-model="minNumberOfVersions" min="1">
                    </td>
                    <td colspan="3">
                        <label for="maxNumberOfVersions">
                            Najveći broj verzija
                        </label>
                        <input type="number" name="maxNumberOfVersions" id="maxNumberOfVersions" v-model="maxNumberOfVersions" min="1">
                    </td>
                </tr>
                <tr>
                    <td colspan="3">
                        <label for="minCreatedDate">
                            Kreirano najranije
                        </label>
                        <input type="datetime-local" name="minCreatedDate" id="minCreatedDate" v-model="minCreatedDate" >
                    </td>
                    <td colspan="3">
                        <label for="maxCreatedDate">
                            Kreirano najkasnije
                        </label>
                        <input type="datetime-local" name="maxCreatedDate" id="maxCreatedDate" v-model="maxCreatedDate" >
                    </td>
                </tr>
                <tr>
                    <td colspan="3">
                        <label for="minLastModifiedDate">
                            Zadnja izmjena najranije
                        </label>
                        <input type="datetime-local" name="minLastModifiedDate" id="minLastModifiedDate" v-model="minLastModifiedDate" >
                    </td>
                    <td colspan="3">
                        <label for="maxLastModifiedDate">
                            Zadnja izmjena najkasnije
                        </label>
                        <input type="datetime-local" name="maxLastModifiedDate" id="maxLastModifiedDate" v-model="maxLastModifiedDate" >
                    </td>
                </tr>
                <tr>
                    <td colspan="3">
                        <label for="hasFinal">
                            Ima finalnu?
                        </label>
                        <select name="hasFinal" id="hasFinal" v-model="hasFinal">
                            <option :value="true">Samo koji ima finalnu verziju</option>
                            <option :value="false">Samo koji nema finalnu verziju</option>
                        </select>
                    </td>
                    <td colspan="3">
                        <label for="created">
                            Stvorio dokument
                        </label>
                        <select name="created" id="created" v-model="created">
                            <option v-for="user in users" :value="user.id">{{ user.naziv }}</option>
                        </select>
                    </td>
                </tr>
                <tr class="form-space"></tr>
                <tr><td colspan="6"><hr></td></tr>
                <tr class="form-space"></tr>
                <tr>
                    <td colspan="3" style="border-right: var(--border);">
                        <table>
                            <tr>
                                <td colspan="6" class="form-center">
                                    <h3>Dijeljeno s grupama</h3>
                                </td>
                            </tr>
                            <tr v-for="(groupValue, groupIndex) in sharedWithGroups">
                                <td colspan="5">
                                    <select v-model="sharedWithGroups[groupIndex]">
                                        <option :value="group.id" v-for="group in groups
                                            .filter((g) => !sharedWithGroups.includes(g.id) || g.id == groupValue)">{{ group.naziv }}</option>
                                    </select>
                                </td>
                                <td colspan="1">
                                    <input type="button" v-on:click="removeGroup(groupIndex)" value="-">
                                </td>
                            </tr>
                            <tr>
                                <td colspan="1">
                                    <input type="button" v-if="sharedWithGroups.length < groups.length" v-on:click="addNewGroup" value="+">
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td colspan="3">
                        <table>
                            <tr>
                                <td colspan="6" class="form-center">
                                    <h3>Dijeljeno s korisnicima</h3>
                                </td>
                            </tr>
                            <tr v-for="(userValue, userIndex) in sharedWithUsers">
                                <td colspan="5">
                                    <select v-model="sharedWithUsers[userIndex]">
                                        <option :value="user.id" v-for="user in users
                                            .filter((u) => !sharedWithUsers.includes(u.id) || u.id == userValue)">{{ user.naziv }}</option>
                                    </select>
                                </td>
                                <td colspan="1">
                                    <input type="button" v-on:click="removeUser(userIndex)" value="-">
                                </td>
                            </tr>
                            <tr>
                                <td colspan="1">
                                    <input type="button" v-if="sharedWithUsers.length < users.length" v-on:click="addNewUser" value="+">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr class="form-space"></tr>
                <tr><td colspan="6"><hr></td></tr>
                <tr class="form-space"></tr>
                <tr>
                    <td colspan="1">
                        <input type="button" value="Očisti filtere" v-on:click="clearFilters">
                    </td>
                    <td colspan="1">
                        <input type="button" value="Očisti rezultate" v-on:click="clearResults">
                    </td>
                    <td colspan="2" class="form-center">
                        <button style="width: 50%;" type="submit">Pretraži</button>
                    </td>
                </tr>
                <tr>
                    <td colspan="6" class="form-center">
                        <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
                    </td>
                </tr>
            </table>
        </form>
        
    </div>
    <h2>Rezultati</h2>
    <div class="content">
        <DocumentList method="POST" path="advancedSearch" ref="documentListComponent" loadOnMounted="false" />
    </div>
</template>