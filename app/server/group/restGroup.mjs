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

    postGroup = (req, res) => {
        res.type("application/json");
        let auth = new Auth(this.config.jwtConfig);

        auth.checkAuth(req)
            .then((userId) => {
                let groupName = req.body.groupName;

                let groupService = new GroupService(this.config);
                groupService.createGroup(groupName, userId)
                    .then(async () => {
                        res.status(201);
                        res.send(JSON.stringify({
                            "success": true,
                            "text": "Grupa uspješno kreirana!"
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

    putGroupMember = (req, res) => {
        res.type("application/json");
        let auth = new Auth(this.config.jwtConfig);

        auth.checkAuth(req)
            .then((userId) => {
                let memberId = req.body.memberId;
                let groupId = req.body.groupId;

                let groupService = new GroupService(this.config);
                groupService.addMemberToGroup(memberId, groupId, userId)
                    .then(async () => {
                        res.status(201);
                        res.send(JSON.stringify({
                            "success": true,
                            "text": "Korisnik je dodan u grupu!"
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

    deleteGroupMember = (req, res) => {
        res.type("application/json");
        let auth = new Auth(this.config.jwtConfig);

        auth.checkAuth(req)
            .then((userId) => {
                let memberId = req.body.memberId;
                let groupId = req.body.groupId;

                let groupService = new GroupService(this.config);
                groupService.removeMemberFromGroup(memberId, groupId, userId)
                    .then(async () => {
                        res.status(201);
                        res.send(JSON.stringify({
                            "success": true,
                            "text": "Korisnik je uklonjen iz grupe!"
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
}

export default RestGroup;