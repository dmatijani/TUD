import fs from "fs";
import DB from "../db/db.mjs";

class DocumentService {
    constructor(config) {
        this.config = config;
    }

    uploadFirstDocumentVersion = async function(userId, name, description, documentType, final, note, groupsToShare, usersToShare, filepath, filename) {
        var db = new DB(this.config.dbConfig);
        await db.connect();
        try {
            var groupsToShareJson = JSON.stringify(groupsToShare);
            var usersToShareJson = JSON.stringify(usersToShare);

            let params = [userId, name, description, documentType, final, note, groupsToShareJson, usersToShareJson, filepath, filename];
            let newDocumentId = await db.execute("SELECT prva_verzija_dokumenta($1, $2, $3, $4, $5, $6, $7, $8, $9, $10);", params);
            return newDocumentId[0].prva_verzija_dokumenta;
        } catch (error) {
            throw error;
        } finally {
            await db.close();

            if (fs.existsSync(filepath)) {
                fs.unlink(filepath, () => {});
            }
        }
    }

    getDocumentList = async function(userId, role) {
        if (role != 'vlasnik' && role != 'čitanje') {
            throw new Error("Uloga mora biti 'vlasnik' ili 'čitanje'!");
        }

        var db = new DB(this.config.dbConfig);
        await db.connect();
        try {
            let params = [userId];
            let functionName = role == 'vlasnik' ? 'dohvati_popis_mojih_dokumenata' : 'dohvati_popis_dijeljenih_dokumenata';
            let documents = await db.execute(`SELECT * FROM ${functionName}($1);`, params);
            return documents;
        } catch (error) {
            throw error;
        } finally {
            await db.close();
        }
    }

    getDocumentDetails = async function(userId, documentId) {
        var db = new DB(this.config.dbConfig);
        await db.connect();
        try {
            let params = [userId, documentId];
            let documents = await db.execute("SELECT * FROM dohvati_detalje_dokumenta($1, $2);", params);
            
            if (documents == undefined || documents.length != 1) {
                throw new Error("Nemogućnost pronalaženja dokumenta.");
            }

            let document = documents[0];
            
            return document;
        } catch (error) {
            throw error;
        } finally {
            await db.close();
        }
    }

    getFileName = async function(userId, fileId) {
        var db = new DB(this.config.dbConfig);
        await db.connect();
        try {
            let params = [userId, fileId];
            let files = await db.execute("SELECT * FROM preuzmi_datoteku($1, $2);", params);
            let file = files[0];

            return file;
        } catch (error) {
            await db.close();
        }
    }
}

export default DocumentService;