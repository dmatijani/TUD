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
    successMessage.value = "";
    errorMessage.value = "";

    const getUsersResponse = await rest.sendRequest("GET", `/users/notInGroup/${groupId}`, undefined, true);

    if (getUsersResponse.success) {
        users.value = getUsersResponse.users;
        selectedUserId.value = null;
    } else {
        errorMessage.value = response.error;
    }
}

defineExpose({
    loadUsers
});

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
        await loadUsers();
        emit("userAdded");
        successMessage.value = response.text;
    } else {
        errorMessage.value = response.error;
    }
}
</script>

<template>
    <div class="content">
        <div v-if="users != null">
            <p v-if="users.length == 0">Nema korisnika za dodati!</p>
            <form v-else @submit.prevent="submitForm" id="newUserForm">
                <table>
                    <tr>
                        <td colspan="5">
                            <h3>Dodavanje članova</h3>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <label for="user">
                                Novi korisnik
                            </label>
                        </td>
                        <td colspan="3">
                            <select name="user" id="userId" form="newUserForm" v-model="selectedUserId">
                                <option v-for="user in users" :value="user.id">{{ user.ime }} {{ user.prezime }}</option>
                            </select>
                        </td>
                        <td></td>
                    </tr>
                    <tr class="form-space"></tr>
                    <tr>
                        <td colspan="2"></td>
                        <td class="form-center">
                            <button type="submit">Prijavi</button>
                        </td>
                        <td colspan="2"></td>
                    </tr>
                    <tr>
                        <td colspan="5" class="form-center">
                            <SuccessMessage v-if="successMessage != null && successMessage != ''">{{ successMessage }}</SuccessMessage>
                            <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
                        </td>
                    </tr>
                </table>
            </form>
        </div>
    </div>
</template>