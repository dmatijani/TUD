<script setup>
import Authenticated from "../components/Authenticated.vue";
import NotAuthenticated from "../components/NotAuthenticated.vue";
</script>

<template>
    <main>
        <p>Početna stranica</p>
        <Authenticated>
            <p>Dobrodošli!</p>
        </Authenticated>
        <NotAuthenticated>
            <p>Morate se prijaviti.</p>
        </NotAuthenticated>
    </main>
</template>
