import GroupService from "./groupService.mjs";
import Auth from "../user/auth.mjs";

class RestGroup {
    constructor(config) {
        this.config = config;
    }

    getGroupDetails = (req, res) => {
        res.type("application/json");
        let auth = new Auth(this.config.jwtConfig);

        auth.checkAuth(req)
            .then((userId) => {
                let groupId = req.params.groupId;

                let groupService = new GroupService(this.config);
                groupService.getGroupDetails(groupId, userId)
                    .then(async (groupDetails) => {
                        res.status(200);
                        res.send(JSON.stringify({
                            "success": true,
                            "text": "uspjesno",
                            "group": groupDetails
                        }));
                    })
                    .catch((error) => {
                        throw error;
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

export default RestGroup;