<script setup>
import { RouterLink, RouterView } from 'vue-router'
import NavigationBar from "./components/NavigationBar.vue";
</script>

<template>
    <header>
        <h1>TUD</h1>
    </header>

    <nav>
        <NavigationBar />
    </nav>

    <main>
        <RouterView />
    </main>
</template>
