import RoleService from "./restRole.mjs";

class RestRole {
    constructor(config) {
        this.config = config;
    }

    getRoles = (req, res) => {
        res.type("application/json");

        let roleService = new RoleService(this.config);
        roleService.getRoles()
            .then(async (roles) => {
                res.status(200);
                res.send(JSON.stringify({
                    "success": true,
                    "text": "uspjesno",
                    "roles": roles.map((role) => ({
                        "name": role.naziv,
                        "actions": role.radnje
                    }))
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

export default RestRole;