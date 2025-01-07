import formidable from "formidable";

class RestDocument {
    constructor(config) {
        this.config = config;
    }

    postDocument = (req, res) => {
        res.type("application/json");

        var form = formidable()
        form.parse(req, (error, fields, files) => {
            if (error) {
                res.status(400);
                res.send(JSON.stringify({
                    "success": false,
                    "error": error.message
                }));
                return;
            }

            try {
                let newDocumentId = handleFileUpload(fields, files);
                
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

function handleFileUpload(fields, files) {
    let fieldsParsed = Object.fromEntries(
        Object.entries(fields).map(([key, value]) => [key, value[0]])
    );

    let file = files.file[0];
    let filepath = file.filepath;
    let filename = file.originalFilename;

    console.log(fieldsParsed);
    console.log(filepath);
    console.log(filename);

    return 69;
}

export default RestDocument;