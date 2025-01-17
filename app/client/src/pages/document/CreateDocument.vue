<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from 'vue-router';
import AuthController from "../../services/authController.mjs";
import RestServices from "../../services/rest.mjs";
import SuccessMessage from "../../components/SuccessMessage.vue";
import ErrorMessage from "../../components/ErrorMessage.vue";

const authController = new AuthController();
const rest = new RestServices();
const router = useRouter();

const successMessage = ref("");
const errorMessage = ref("");

const newDocumentId = ref(null);

const docTypes = ref([]);
const roles = ref([]);
const groups = ref([]);
const users = ref([]);

const name = ref("");
const description = ref("");
const documentType = ref("");
const final = ref(false);
const note = ref("");
const file = ref(null);

const groupsToShare = ref([]);
const addNewGroup = () => {
    groupsToShare.value.push({
        selectedGroup: groups.value.filter((g) => !groupsToShare.value.map((s) => s.selectedGroup).includes(g.id)).map((g) => g.id)[0],
        selectedRole: null
    });
}

const removeGroup = (index) => {
    groupsToShare.value.splice(index, 1);
}

const usersToShare = ref([]);
const addNewUser = () => {
    usersToShare.value.push({
        selectedUser: users.value.filter((u) => !usersToShare.value.map((s) => s.selectedUser).includes(u.id)).map((u) => u.id)[0],
        selectedRole: null
    });
}

const removeUser = (index) => {
    usersToShare.value.splice(index, 1);
}

const loadTypes = async() => {
    const getTypesResponse = await rest.sendRequest("GET", "/types");

    if (getTypesResponse.success) {
        docTypes.value = getTypesResponse.types;
    }
}

const loadRoles = async() => {
    const getRolesResponse = await rest.sendRequest("GET", "/roles");

    if (getRolesResponse.success) {
        roles.value = getRolesResponse.roles;
    }
}

const loadGroupsAndUsersForUser = async () => {
    const getGroupsAndRolesResponse = await rest.sendRequest("GET", "/group/groupsAndUsersForUser", undefined, true);

    if (getGroupsAndRolesResponse.success) {
        groups.value = getGroupsAndRolesResponse.groups;
        let allUsers = [].concat.apply([], getGroupsAndRolesResponse.groups.map((g) => g.korisnici));
        users.value = allUsers.filter(
            (user, index, self) => index === self.findIndex(u => u.korisnik_id === user.korisnik_id)
        ).map((u) => ({
            id: u.korisnik_id,
            name: u.korisnik
        }));
    }
}

onMounted(async () => {
    if (!authController.isAuthenticated()) {
        router.push({ name: 'prijava' });
        return;
    }

    await loadTypes();
    await loadRoles();
    await loadGroupsAndUsersForUser();
});

const handleFileChanged = (event) => {
    file.value = event.target.files[0];
}

const submitForm = async () => {
    successMessage.value = "";
    errorMessage.value = "";

    if (!file.value) {
        errorMessage.value = "Molimo odaberite datoteku!";
        return;
    }
    
    const formData = new FormData();
    formData.append("name", name.value);
    formData.append("description", description.value);
    formData.append("documentType", documentType.value);
    formData.append("final", final.value);
    formData.append("note", note.value);
    formData.append("file", file.value);
    formData.append("groupsToShare", JSON.stringify(groupsToShare.value.filter((g) => g.selectedGroup != null && g.selectedRole != null)));
    formData.append("usersToShare", JSON.stringify(usersToShare.value.filter((u) => u.selectedUser != null && u.selectedRole != null)));

    const response = await rest.sendRequest("POST", "/document/create", formData, true, "multipart/form-data");

    if (response.success) {
        newDocumentId.value = response.newDocumentId;
        successMessage.value = response.text;
    } else {
        errorMessage.value = response.error;
    }
};
</script>

<template>
    <h2>Kreiraj dokument</h2>
    <div class="content">
        <form @submit.prevent="submitForm">
            <table>
                <tr>
                    <td colspan="10" class="form-center">
                        <h3>Osnovno</h3>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label for="name">
                            Naziv dokumenta
                        </label>
                    </td>
                    <td colspan="6">
                        <input type="text" id="name" v-model="name" placeholder="Naziv dokumenta" required />
                    </td>
                    <td colspan="2"></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label for="description">
                            Opis dokumenta
                        </label>
                    </td>
                    <td colspan="6">
                        <textarea id="description" v-model="description" placeholder="Opis" rows="5"></textarea>
                    </td>
                    <td colspan="2"></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label for="documentType">
                            Vrsta dokumenta
                        </label>
                    </td>
                    <td colspan="6">
                        <select name="documentType" id="documentType" v-model="documentType">
                            <option v-for="docType in docTypes" :value="docType">{{ docType }}</option>
                        </select>
                    </td>
                    <td colspan="2"></td>
                </tr>
                <tr class="form-space"></tr>
                <tr><td colspan="10"><hr></td></tr>
                <tr class="form-space"></tr>
                <tr>
                    <td colspan="10" class="form-center">
                        <h3>Prva verzija</h3>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label for="note">
                            Bilješka uz prvu verziju
                        </label>
                    </td>
                    <td colspan="6">
                        <input type="text" id="note" v-model="note" placeholder="Bilješka uz prvu verziju">
                    </td>
                    <td colspan="2"></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label for="final">
                            Finalna?
                        </label>
                    </td>
                    <td colspan="1">
                        <input type="checkbox" id="final" name="final" v-model="final" />
                    </td>
                    <td colspan="7"></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label for="file">
                            Datoteka
                        </label>
                    </td>
                    <td colspan="6">
                        <input type="file" id="file" @change="handleFileChanged" placeholder="Početna datoteka" required />
                    </td>
                    <td colspan="2"></td>
                </tr>
                <tr class="form-space"></tr>
                <tr><td colspan="10"><hr></td></tr>
                <tr class="form-space"></tr>
                <tr>
                    <td colspan="4" class="form-center">
                        <table>
                            <tr>
                                <td colspan="6" class="form-center">
                                    <h3>Dodijeli pravo korištenja pojedinim korisnicima</h3>
                                </td>
                            </tr>
                            <tr v-for="(groupValue, groupIndex) in groupsToShare">
                                <td colspan="3">
                                    <select v-model="groupValue.selectedGroup">
                                        <option :value="possibleGroup.id" v-for="possibleGroup in groups.filter((g) => 
                                                    !groupsToShare.map((s) => s.selectedGroup).includes(g.id) || g.id == groupValue.selectedGroup
                                                ).map((gg) => ({ id: gg.id, name: gg.naziv }))">
                                                {{ possibleGroup.name }}
                                        </option>
                                    </select>
                                </td>
                                <td colspan="2">
                                    <select v-model="groupValue.selectedRole">
                                        <option v-for="possibleRole in roles" :value="possibleRole">{{ possibleRole }}</option>
                                    </select>
                                </td>
                                <td colspan="1">
                                    <input type="button" v-on:click="removeGroup(groupIndex)" value="-">
                                </td>
                            </tr>
                            <tr>
                                <td colspan="1">
                                    <input type="button" v-if="groupsToShare.length < groups.length" v-on:click="addNewGroup" value="+">
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td colspan="2"></td>
                    <td colspan="4" class="form-center">
                        <table>
                            <tr>
                                <td colspan="6" class="form-center">
                                    <h3>Dodijeli pravo korištenja pojedinim korisnicima</h3>
                                </td>
                            </tr>
                            <tr v-for="(userValue, userIndex) in usersToShare">
                                <td colspan="3">
                                    <select v-model="userValue.selectedUser">
                                        <option :value="possibleUser.id" v-for="possibleUser in users.filter((u) => 
                                                    !usersToShare.map((s) => s.selectedUser).includes(u.id) || u.id == userValue.selectedUser)">
                                                {{ possibleUser.name }}
                                        </option>
                                    </select>
                                </td>
                                <td colspan="2">
                                    <select v-model="userValue.selectedRole">
                                        <option v-for="possibleRole in roles" :value="possibleRole">{{ possibleRole }}</option>
                                    </select>
                                </td>
                                <td colspan="1">
                                    <input type="button" v-on:click="removeUser(userIndex)" value="-">
                                </td>
                            </tr>
                            <tr>
                                <td colspan="1">
                                    <input type="button" v-if="usersToShare.length < users.length" v-on:click="addNewUser" value="+">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr class="form-space"></tr>
                <tr>
                    <td colspan="4"></td>
                    <td colspan="2" class="form-center">
                        <button type="submit">Prenesi prvu verziju dokumenta</button>
                    </td>
                    <td colspan="4"></td>
                </tr>
                <tr>
                    <td colspan="10" class="form-center">
                        <SuccessMessage v-if="successMessage != null && successMessage != ''">
                            <span>{{ successMessage }}</span>
                            <RouterLink :to="'/document/' + newDocumentId">Odi na novokreirani dokument</RouterLink>
                        </SuccessMessage>
                        <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
                    </td>
                </tr>
            </table>
        </form>
    </div>
</template>