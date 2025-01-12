import formidable from "formidable";
import DocumentService from "./documentService.mjs";
import Auth from "../user/auth.mjs";
import fs from "fs";

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

    getDocuments = (req, res) => {
        res.type("application/json");
        let auth = new Auth(this.config.jwtConfig);

        auth.checkAuth(req)
            .then((userId) => {
                let role = req.params.role;

                let documentService = new DocumentService(this.config);
                documentService.getDocumentList(userId, role)
                    .then(async (documents) => {
                        res.status(200);
                        res.send(JSON.stringify({
                            "success": true,
                            "text": "uspjesno",
                            "documents": documents
                        }));
                    })
                    .catch((error) => {
                        res.status(400);
                        res.send(JSON.stringify({
                            "success": false,
                            "error": error.message
                        }));
                    })
            })
            .catch((error) => {
                res.status(400);
                res.send(JSON.stringify({
                    "success": false,
                    "error": error.message
                }));
            })
    }

    getDocument = (req, res) => {
        res.type("application/json");
        let auth = new Auth(this.config.jwtConfig);

        auth.checkAuth(req)
            .then((userId) => {
                let documentId = req.params.documentId;

                let documentService = new DocumentService(this.config);
                documentService.getDocumentDetails(userId, documentId)
                    .then(async (document) => {
                        res.status(200);
                        res.send(JSON.stringify({
                            "success": true,
                            "text": "uspjesno",
                            "document": document
                        }));
                    })
                    .catch((error) => {
                        res.status(400);
                        res.send(JSON.stringify({
                            "success": false,
                            "error": error.message
                        }));
                    })
            })
            .catch((error) => {
                res.status(400);
                res.send(JSON.stringify({
                    "success": false,
                    "error": error.message
                }));
            })
    }

    getDocumentDownload = (req, res) => {
        res.type("application/octet-stream");
        let auth = new Auth(this.config.jwtConfig);

        auth.checkAuth(req)
            .then((userId) => {
                let fileId = req.params.fileId;

                let documentService = new DocumentService(this.config);
                documentService.getFileName(userId, fileId)
                    .then(async (file) => {
                        let tempPath = file.temp_naziv;
                        let fileName = file.naziv_datoteke;
                        res.download(tempPath, fileName, async () => {
                            await documentService.freeFile(tempPath);
                        });
                    })
                    .catch((error) => {
                        res.status(400);
                        res.send(JSON.stringify({
                            "success": false,
                            "error": error.message
                        }));
                    })
            })
            .catch((error) => {
                res.status(400);
                res.send(JSON.stringify({
                    "success": false,
                    "error": error.message
                }));
            })
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
            JSON.parse(fieldsParsed.groupsToShare),
            JSON.parse(fieldsParsed.usersToShare),
            filepath,
            filename
        );
        
        return newDocumentId;
    } catch (error) {
        throw error;
    }
}


export default RestDocument;