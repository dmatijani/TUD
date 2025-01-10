import fs from "fs";
import DB from "../db/db.mjs";

class DocumentService {
    constructor(config) {
        this.config = config;
    }

    uploadFirstDocumentVersion = async function(userId, name, description, documentType, final, note, groupsToShare, usersToShare, filepath, filename) {
        console.log(userId);
        console.log(name);
        console.log(description);
        console.log(documentType);
        console.log(final);
        console.log(note);
        console.log(groupsToShare);
        console.log(usersToShare);
        console.log(filepath);
        console.log(filename);

        // TODO: proslijediti sve ovo u bazinu proceduru

        // TODO: vratiti odgovor (kao kod dodavanja nove grupe)

        if (fs.existsSync(filepath)) {
            fs.unlink(filepath, () => {});
        }

        return 100;
    }
}

export default DocumentService;