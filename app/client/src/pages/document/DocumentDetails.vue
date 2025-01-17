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

const navigate = (path) => {
    router.push(path);
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
    <h2>Detalji dokumenta <span v-if="documentData">'{{ documentData.naziv }}'</span></h2>
    <div class="content">
        <ErrorMessage v-if="errorMessage != null && errorMessage != ''">{{ errorMessage }}</ErrorMessage>
        <div class="section" v-if="documentData != null">
            <h3>Osnovno</h3>
            <ul>
                <li>Naziv: <span>{{ documentData.naziv }}</span></li>
                <li>Opis: <span>{{ documentData.opis }}</span></li>
                <li>Vrsta: <span>{{ documentData.vrsta }}</span></li>
                <li v-if="documentData.pravo == 'vlasnik'">Vi ste vlasnik dokumenta</li>
            </ul>
        </div>
        <div style="height: var(--form-space);"></div>
        <div class="section" v-if="documentData != null">
            <h3>Verzije</h3>
            <div v-if="documentData.pravo == 'vlasnik' && !documentData.ima_finalnu">
                <button v-on:click="navigate('/documents/newVersion/' + documentId)">Dodaj novu verziju</button>
            </div>
            <ul>
                <li v-for="verzija in documentData.verzije">
                    <div style="height: var(--form-space);"></div>
                    <ul>
                        <li><h4>Verzija {{ verzija.verzija }}<span v-if="verzija.finalna"> - finalna verzija</span></h4></li>
                        <li>Kreirana: <span>{{ (new Date(verzija.vrijedi_od)).toLocaleString() }} od korisnika {{ verzija.kreirao }}</span></li>
                        <li>Napomena: <span>{{ verzija.napomena }}</span></li>
                        <li>Datoteka: <span>{{ verzija.naziv_datoteke }}</span></li>
                        <li><button v-on:click="downloadFile(verzija.datoteka_id, verzija.naziv_datoteke)">Preuzmi</button></li>
                    </ul>
                </li>
            </ul>
        </div>
        <div style="height: var(--form-space);"></div>
        <div class="section" v-if="documentData != null">
            <h3>Dijeljeno sa</h3>
            <ul>
                <li v-for="dijeljenoKorisnici in documentData.dijeljeno_s_korisnicima">
                    <span>Korisnik <span>{{ dijeljenoKorisnici.naziv }} - {{ dijeljenoKorisnici.pravo }}</span></span>
                </li>
                <li v-for="dijeljenoGrupa in documentData.dijeljeno_s_grupama">
                    <span>Svi korisnici iz grupe <span>{{ dijeljenoGrupa.naziv }} - {{ dijeljenoGrupa.pravo }}</span></span>
                </li>
            </ul>
        </div>
    </div>
</template>

<style scoped>
ul {
    list-style-type: none;
}

.padding {
    padding: var(--main-padding);
}
</style>