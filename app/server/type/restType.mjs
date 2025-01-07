import TypeService from "./typeService.mjs"

class RestType {
    constructor(config) {
        this.config = config;
    }

    getTypes = (req, res) => {
        res.type("application/json");

        let typeService = new TypeService(this.config);
        typeService.getTypes()
            .then(async (types) => {
                res.status(200);
                res.send(JSON.stringify({
                    "success": true,
                    "text": "uspjesno",
                    "types": types.map((type) => type.vrijednost)
                }));
            })
            .catch((error) => {
                res.status(400);
                res.send(JSON.stringify({
                    "success": false,
                    "error": error.message
                }));
            });
    }
}

export default RestType;