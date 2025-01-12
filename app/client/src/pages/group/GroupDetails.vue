<script setup>
import { ref, onMounted } from "vue";
import { useRoute, useRouter } from 'vue-router';
import RestServices from "../../services/rest.mjs";
import AuthController from "../../services/authController.mjs";
import SuccessMessage from "../../components/SuccessMessage.vue";
import ErrorMessage from "../../components/ErrorMessage.vue";
import GroupAddUsers from "./GroupAddUsers.vue";

const authController = new AuthController();
const route = useRoute();
const router = useRouter();
const rest = new RestServices();

const groupId = route.params.id;

const successMessage = ref("");
const errorMessage = ref("");
const groupData = ref(null);

var userId = ref(null);
var userIsOwner = false;

const groupAddUsersComponent = ref(null);

const loadGroupData = async () => {
    const response = await rest.sendRequest("GET", `/group/${groupId}`, null, true);
    
    if (response.success) {
        groupData.value = response.group;

        userIsOwner = userId.value == response.group.vlasnik_id;
    } else {
        errorMessage.value = response.error;
    }
}

onMounted(async () => {
    if (!groupId) {
        router.push({ name: 'prijava' });
        return;
    }

    if (!authController.isAuthenticated()) {
        router.push({ name: 'prijava' });
        return;
    }

    userId.value = authController.getLoggedInUser().userId;

    await loadGroupData();
});

const handleUserAdded = async() => {
    successMessage.value = "";
    errorMessage.value = "";
    await loadGroupData();
}

const removeUser = async(selectedUserId) => {
    successMessage.value = "";
    errorMessage.value = "";

    const response = await rest.sendRequest("DELETE", "/group/removeMember", {
        memberId: selectedUserId,
        groupId: groupData.value.id
    }, true);

    if (response.success) {
        successMessage.value = response.text;
        await loadGroupData();
        await groupAddUsersComponent.value.loadUsers();
    } else {
        errorMessage.value = response.error;
    }
}
</script>

<template>
    <h2>Grupa <span v-if="groupData">{{ groupData.naziv }}</span></h2>
    <div v-if="groupData != null">
        <h3>Osnovno</h3>
        <li>Naziv: <span>{{ groupData.naziv }}</span></li>
        <li v-if="groupData.vlasnik.trim() != ''">Vlasnik: <span>{{ groupData.vlasnik }}</span><span v-if="userIsOwner" style="font-weight: bold;"> - vi</span></li>
        <li v-if="groupData.email_vlasnika != null">Email vlasnika: <span>{{ groupData.email_vlasnika }}</span></li>
    </div>
    <div v-if="groupData != null">
        <h3>Članovi</h3>
        <ul>
            <li v-for="clan in groupData.clanovi"><ul>
                <li>Ime i prezime: <span>{{ clan.korisnik }}</span></li>
                <li>Vrijeme učlanjivanja: <span>{{ clan.vrijeme_uclanjivanja }}</span></li>
                <li v-if="clan.je_vlasnik">Vlasnik</li>
                <li v-else-if="userIsOwner"><button v-on:click="removeUser(clan.korisnik_id)">Ukloni</button></li>
            </ul></li>
        </ul>
        <SuccessMessage v-if="successMessage != null && successMessage != ''">{{ successMessage }}</SuccessMessage>
        <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>

        <div v-if="userIsOwner">
            <GroupAddUsers :groupId="groupData.id" @userAdded="handleUserAdded" ref="groupAddUsersComponent" />
        </div>
    </div>
</template>
