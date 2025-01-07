import formidable from "formidable";
import DocumentService from "./documentService.mjs";
import Auth from "../user/auth.mjs";

class RestDocument {
    constructor(config) {
        this.config = config;
    }

    postDocument = (req, res) => {
        res.type("application/json");

        var form = formidable()
        form.parse(req, async (error, fields, files) => {
            if (error) {
                res.status(400);
                res.send(JSON.stringify({
                    "success": false,
                    "error": error.message
                }));
                return;
            }

            try {
                let auth = new Auth(this.config.jwtConfig);
                let userId = await auth.checkAuth(req);

                let newDocumentId = await handleFileUpload(this.config, userId, fields, files);
                
                res.send(JSON.stringify({
                    "success": true,
                    "text": "Datoteka uspješno dodana!",
                    "newDocumentId": newDocumentId
                }));
            } catch (error) {
                res.status(400);
                res.send(JSON.stringify({
                    "success": false,
                    "error": error.message
                }));
                return;
            }
        });
    }
}

async function handleFileUpload(config, userId, fields, files) {
    try {
        let fieldsParsed = Object.fromEntries(
            Object.entries(fields).map(([key, value]) => [key, value[0]])
        );
        
        let file = files.file[0];
        let filepath = file.filepath;
        let filename = file.originalFilename;
        
        let documentService = new DocumentService(config);
        let newDocumentId = await documentService.uploadFirstDocumentVersion(
            userId,
            fieldsParsed.name,
            fieldsParsed.description,
            fieldsParsed.documentType,
            fieldsParsed.final,
            fieldsParsed.note,
            filepath,
            filename
        );
        
        return newDocumentId;
    } catch (error) {
        throw error;
    }
}


export default RestDocument;