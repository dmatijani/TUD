<script setup>
import { ref, onMounted } from "vue";
import { useRoute } from 'vue-router';
import { useRouter } from 'vue-router';
import RestServices from "../../services/rest.mjs";
import AuthController from "../../services/authController.mjs";
import ErrorMessage from "../../components/ErrorMessage.vue";

const authController = new AuthController();
const route = useRoute();
const router = useRouter();
const rest = new RestServices();

const documentId = route.params.id;

const errorMessage = ref("");
const documentData = ref(null);

const loadDocumentData = async () => {
    const response = await rest.sendRequest("GET", `/document/${documentId}`, null, true);

    if (response.success) {
        documentData.value = response.document;
    } else {
        errorMessage.value = response.error;
    }
}

onMounted(async () => {
    if (!documentId) {
        router.push({ name: 'prijava' });
        return;
    }

    if (!authController.isAuthenticated()) {
        router.push({ name: 'prijava' });
        return;
    }

    await loadDocumentData();
});
</script>

<template>
    <h2>Detalji dokumenta</h2>
    <div v-if="documentData != null && documentData.pravo == 'vlasnik'">
        <!-- TODO: dodavanje nove verzije dokumentu (ako je korisnik vlasnik) -->
        <p>Dodaj novu verziju ???</p>
    </div>
    <div v-if="documentData != null">
        <h3>Osnovno</h3>
        <ul>
            <li>Naziv: <span>{{ documentData.naziv }}</span></li>
            <li>Opis: <span>{{ documentData.opis }}</span></li>
            <li>Vrsta: <span>{{ documentData.vrsta }}</span></li>
            <li v-if="documentData.pravo == 'vlasnik'">Vi ste vlasnik dokumenta</li>
        </ul>
    </div>
    <div v-if="documentData != null">
        <h3>Verzije</h3>
        <ul>
            <li v-for="verzija in documentData.verzije"><ul>
                <li>Kreirana: <span>{{ verzija.vrijedi_od }}</span></li>
                <li>Verzija: <span>{{ verzija.verzija }}</span></li>
                <li v-if="verzija.finalna">Finalna verzija</li>
                <li>Napomena: <span>{{ verzija.napomena }}</span></li>
                <li>Kreirao: <span>{{ verzija.kreirao }}</span></li>
                <li>Datoteka: <span>{{ verzija.naziv_datoteke }}</span></li> <!-- TODO: da se može downloadati -->
            </ul></li>
        </ul>
    </div>
    <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
</template>