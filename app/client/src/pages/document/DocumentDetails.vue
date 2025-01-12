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

const downloadFile = async (fileId, fileName) => {
    errorMessage.value = "";
    
    const response = await rest.downloadFile(`/document/download/${fileId}`, true, fileName);
    if (!response.success) {
        errorMessage.value = response.error;
    }
}
</script>

<template>
    <h2>Detalji dokumenta</h2>
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
        <div v-if="documentData.pravo == 'vlasnik'">
            <!-- TODO: dodavanje nove verzije dokumentu (ako je korisnik vlasnik) -->
            <p>Dodaj novu verziju ???</p>
        </div>
        <ul>
            <li v-for="verzija in documentData.verzije"><ul>
                <li>Kreirana: <span>{{ verzija.vrijedi_od }}</span></li>
                <li>Verzija: <span>{{ verzija.verzija }}</span></li>
                <li v-if="verzija.finalna">Finalna verzija</li>
                <li>Napomena: <span>{{ verzija.napomena }}</span></li>
                <li>Kreirao: <span>{{ verzija.kreirao }}</span></li>
                <li>Datoteka: <span>{{ verzija.naziv_datoteke }}</span></li>
                <li><button v-on:click="downloadFile(verzija.datoteka_id, verzija.naziv_datoteke)">Preuzmi</button></li>
            </ul></li>
        </ul>
    </div>
    <div v-if="documentData != null">
        <h3>Dijeljeno sa</h3>
        <ul>
            <li v-for="dijeljenoKorisnici in documentData.dijeljeno_s_korisnicima"><ul>
                <li>Naziv: <span>{{ dijeljenoKorisnici.naziv }}</span></li>
                <li>Pravo: <span>{{ dijeljenoKorisnici.pravo }}</span></li>
            </ul></li>
        </ul>
        <ul>
            <li v-for="dijeljenoGrupa in documentData.dijeljeno_s_grupama"><ul>
                <li>Naziv: <span>{{ dijeljenoGrupa.naziv }}</span></li>
                <li>Pravo: <span>{{ dijeljenoGrupa.pravo }}</span></li>
            </ul></li>
        </ul>
    </div>
    <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
</template>