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
        console.log(getTypesResponse);
        docTypes.value = getTypesResponse.types;
    }
}

const loadRoles = async() => {
    const getRolesResponse = await rest.sendRequest("GET", "/roles");

    if (getRolesResponse.success) {
        console.log(getRolesResponse);
        roles.value = getRolesResponse.roles;
    }
}

const loadGroupsAndUsersForUser = async() => {
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
    <form @submit.prevent="submitForm">
        <fieldset>
            <label for="name">
                Naziv dokumenta
            </label>
            <input type="text" id="name" v-model="name" placeholder="Naziv dokumenta" required />
            <label for="description">
                Opis dokumenta
            </label>
            <textarea id="description" v-model="description" placeholder="Opis" rows="5"></textarea>
            <label for="documentType">
                Vrsta dokumenta
            </label>
            <select name="documentType" id="documentType" v-model="documentType">
                <option v-for="docType in docTypes" :value="docType">{{ docType }}</option>
            </select>
            <hr />
            <label for="note">
                Bilješka uz prvu verziju
            </label>
            <textarea id="note" v-model="note" placeholder="Bilješka uz prvu verziju" rows="3"></textarea>
            <label for="final">
                Finalna?
            </label>
            <input type="checkbox" id="final" name="final" v-model="final" />
            <label for="file">
                Datoteka
            </label>
            <input type="file" id="file" @change="handleFileChanged" placeholder="Početna datoteka" required />
            <hr />
            <h3>Dodijeli pravo korištenja grupama</h3>
            <div v-for="(groupValue, groupIndex) in groupsToShare">
                <select v-model="groupValue.selectedGroup">
                    <option :value="possibleGroup.id" v-for="possibleGroup in groups.filter((g) => 
                                !groupsToShare.map((s) => s.selectedGroup).includes(g.id) || g.id == groupValue.selectedGroup
                            ).map((gg) => ({ id: gg.id, name: gg.naziv }))">
                            {{ possibleGroup.name }}
                    </option>
                </select>
                <select v-model="groupValue.selectedRole">
                    <option v-for="possibleRole in roles" :value="possibleRole">{{ possibleRole }}</option>
                </select>
                <input type="button" v-on:click="removeGroup(groupIndex)" value="-">
            </div>
            <input type="button" v-if="groupsToShare.length < groups.length" v-on:click="addNewGroup" value="+">
            <hr />
            <h3>Dodijeli pravo korištenja pojedinim korisnicima</h3>
            <div v-for="(userValue, userIndex) in usersToShare">
                <select v-model="userValue.selectedUser">
                    <option :value="possibleUser.id" v-for="possibleUser in users.filter((u) => 
                                !usersToShare.map((s) => s.selectedUser).includes(u.id) || u.id == userValue.selectedUser)">
                            {{ possibleUser.name }}
                    </option>
                </select>
                <select v-model="userValue.selectedRole">
                    <option v-for="possibleRole in roles" :value="possibleRole">{{ possibleRole }}</option>
                </select>
                <input type="button" v-on:click="removeUser(userIndex)" value="-">
            </div>
            <input type="button" v-if="usersToShare.length < users.length" v-on:click="addNewUser" value="+">
            <hr />
            <button type="submit">Prenesi prvu verziju dokumenta</button>
        </fieldset>
    </form>
    <SuccessMessage v-if="successMessage != null && successMessage != ''">
        <span>{{ successMessage }}</span>
        <RouterLink :to="'/documents/myDocuments/' + newDocumentId">Odi na prijavu</RouterLink> <!-- TODO: odi na novokreirani dokument -->
    </SuccessMessage>
    <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
</template>