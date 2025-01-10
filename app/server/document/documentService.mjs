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
}

export default DocumentService;