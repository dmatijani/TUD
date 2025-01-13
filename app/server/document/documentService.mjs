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

            await this.freeFile(filepath);
        }
    }

    uploadNewDocumentVersion = async function(userId, documentId, final, note, filepath, filename) {
        var db = new DB(this.config.dbConfig);
        await db.connect();
        try {
            let params = [userId, documentId, final, note, filepath, filename];
            await db.execute("SELECT nova_verzija_dokumenta($1, $2, $3, $4, $5, $6);", params);
        } catch (error) {
            throw error;
        } finally {
            await db.close();

            await this.freeFile(filepath);
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

    advancedSearch = async function(userId, body) {
        var db = new DB(this.config.dbConfig);
        await db.connect();
        try {
            let params = [
                userId,
                body.namePart,
                body.documentType,
                body.minNumberOfVersions,
                body.maxNumberOfVersions,
                body.minCreatedDate,
                body.maxCreatedDate,
                body.minLastModifiedDate,
                body.maxLastModifiedDate,
                body.hasFinal,
                body.created,
                (body.sharedWithGroups.length == 0) ? null : body.sharedWithGroups,
                (body.sharedWithUsers.length == 0) ? null : body.sharedWithUsers
            ];
            let documents = await db.execute("SELECT * FROM napredno_pretrazivanje($1, $2, $3, $4, $5, tsrange(COALESCE($6::TIMESTAMP, '-infinity'::TIMESTAMP), COALESCE($7::TIMESTAMP, 'infinity'::TIMESTAMP)), tsrange(COALESCE($8::TIMESTAMP, '-infinity'::TIMESTAMP), COALESCE($9::TIMESTAMP, 'infinity'::TIMESTAMP)), $10, $11, $12, $13);", params);
            return documents;
        } catch (error) {
            throw error;
        } finally {
            await db.close();
        }
    }

    freeFile = async function(filePath) {
        setTimeout(() => {
            try {
                if (fs.existsSync(filePath)) {
                    fs.unlink(filePath, () => {});
                }
            } catch (error) { }
        }, 1000);
    }
}

export default DocumentService;