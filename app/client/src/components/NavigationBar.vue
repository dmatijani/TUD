<script setup>
import Authenticated from "../components/Authenticated.vue";
import NotAuthenticated from "../components/NotAuthenticated.vue";
</script>

<template>
<RouterLink to="/">Home</RouterLink>
<NotAuthenticated>
    <RouterLink to="/login">Prijava</RouterLink>
</NotAuthenticated>
<Authenticated>
    <p>Odjava</p> <!-- OVO doraditi kasnije -->
</Authenticated>
</template>