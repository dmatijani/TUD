<script setup>
import { RouterView } from 'vue-router'
import NavigationBar from "./components/NavigationBar.vue";
import Authenticated from "./components/Authenticated.vue";

import AuthController from "./services/authController.mjs";

const loggedInUserName = () => {
    const authController = new AuthController();
    let user = authController.getLoggedInUser();
    return `${user.name} ${user.surname}`;
}
</script>

<template>
    <header>
        <p>TUD</p>
        <Authenticated>
            <span>Prijavljen: {{ loggedInUserName() }}</span>
        </Authenticated>
    </header>

    <nav>
        <NavigationBar />
    </nav>

    <main>
        <RouterView />
    </main>
</template>

<style scoped>
header {
    width: 100%;
    background-color: var(--main-bg-color);
    border-bottom: var(--border-width) solid var(--main-border-color);
    padding: var(--main-padding);
    position: fixed;
    display: flex;
}

header p {
    font-weight: bold;
    height: 1em;
}

header span {
    margin-left: auto;
    height: 1em;
}

nav {
    background-color: var(--bg-color);
    border-right: var(--border);
    width: var(--nav-width);
    height: 100%;
    position: fixed;
    margin-top: calc(1em + 2*var(--main-padding) + var(--border-width));
}

main {
    margin-left: var(--nav-width);
    padding-top: calc(1em + 2*var(--main-padding) + var(--border-width));
}
</style>