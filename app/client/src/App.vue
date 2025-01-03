<script setup>
import { RouterLink, RouterView } from 'vue-router'
</script>

<template>
    <header>
        <h1>TUD</h1>

        <div class="wrapper">
            <nav>
            <RouterLink to="/">Home</RouterLink>
            <RouterLink to="/login">Prijava</RouterLink>
            </nav>
        </div>
    </header>

    <RouterView />
</template>
