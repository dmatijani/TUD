<script setup>
import { ref } from "vue";
import { onMounted } from 'vue';
import RestServices from "../../services/rest.mjs";
import SuccessMessage from "../../components/SuccessMessage.vue";
import ErrorMessage from "../../components/ErrorMessage.vue";

const rest = new RestServices();

const successMessage = ref("");
const errorMessage = ref("");

const props = defineProps(["groupId"]);
const emit = defineEmits(["userAdded"]);

let groupId = null;

const users = ref(null);
const selectedUserId = ref(null);

const loadUsers = async() => {
    const getUsersResponse = await rest.sendRequest("GET", `/users/notInGroup/${groupId}`, undefined, true);

    if (getUsersResponse.success) {
        users.value = getUsersResponse.users;
    } else {
        errorMessage.value = response.error;
    }
}

onMounted(async () => {
    groupId = props.groupId;

    await loadUsers();
});

const submitForm = async() => {
    successMessage.value = "";
    errorMessage.value = "";

    if (selectedUserId.value == null || selectedUserId.value == undefined) {
        errorMessage.value = "Niste odabrali korisnika!";
        return;
    }

    const response = await rest.sendRequest("PUT", "/group/addMember", {
        memberId: selectedUserId.value,
        groupId: groupId
    }, true);

    if (response.success) {
        successMessage.value = response.text;
        await loadUsers();
        emit("userAdded");
    } else {
        errorMessage.value = response.error;
    }
}
</script>

<template>
    <h3>Dodavanje članova</h3>
    <div v-if="users != null">
        <p v-if="users.length == 0">Nema korisnika za dodati!</p>
        <form v-else @submit.prevent="submitForm" id="newUserForm">
            <fieldset>
                <label for="user">
                    Novi korisnik
                </label>
                <select name="user" id="userId" form="newUserForm" v-model="selectedUserId">
                    <option v-for="user in users" :value="user.id">{{ user.ime }} {{ user.prezime }}</option>
                </select>
                <button type="submit">Prijavi</button>
            </fieldset>
        </form>
    </div>
    <SuccessMessage v-if="successMessage != null && successMessage != ''">{{ successMessage }}</SuccessMessage>
    <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
</template>