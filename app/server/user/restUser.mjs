import UserService from "./userService.mjs";
import JWT from "../jwt/jwt.mjs";
import Auth from "./auth.mjs";

class RestUser {
    constructor(config) {
        this.config = config;
    }

    getUserJwt = (req, res) => {
        res.type("application/json");
        let auth = new Auth(this.config.jwtConfig);

        if (!auth.checkSession(req)) {
            res.status(401);
            res.send(JSON.stringify({
                "success": false,
                "error": "Potrebna prijava"
            }));
            return;
        }

        let id = req.session.user_id;

        let userService = new UserService(this.config);
        userService.getUserData(id)
            .then(async (user) => {
                res.status(200);
                let jwt = new JWT(this.config.jwtConfig);
                let token = jwt.generateToken(user);
                res.send(JSON.stringify({
                    "success": true,
                    "text": "uspjesno",
                    "token": token
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

    postUserLogin = (req, res) => {
        res.type("application/json");

        let userService = new UserService(this.config);

        let body = req.body;
        userService.logInUser(body)
            .then(async (user) => {
                res.status(201);
                if (req.session.username == null || req.session.username == undefined
                    || req.session.id == null || req.session.id == undefined) {
                    req.session.username = user.username;
                    req.session.user_id = user.user_id;
                }
                res.send(JSON.stringify({
                    "success": true,
                    "text": "uspjesno",
                    "user": user
                }));
            })
            .catch((error) => {
                res.status(400);
                res.send(JSON.stringify({
                    "success": false,
                    "error": error.message
                }));
            });
    };

    postUserRegister = (req, res) => {
        res.type("application/json");

        let userService = new UserService(this.config);

        let body = req.body;
        userService.registerUser(body)
            .then(async () => {
                res.status(201);
                res.send(JSON.stringify({
                    "success": true,
                    "text": "uspjesno"
                }));
            })
            .catch((error) => {
                res.status(400);
                res.send(JSON.stringify({
                    "success": false,
                    "error": error.message
                }));
            })
    }

    getUserLogout = (req, res) => {
        res.type("application/json");
        if (req.session) {
            req.session.destroy((error) => {});
            res.status(201);
            res.send(JSON.stringify({
                "success": true,
                "text": "uspjesno"
            }));
            return;
        }

        res.status(400);
        res.send(JSON.stringify({
            "success": false,
            "error": "Korisnik je već odjavljen."
        }));
    };

    getUserProfile = (req, res) => {
        res.type("application/json");
        let auth = new Auth(this.config.jwtConfig);

        auth.checkAuth(req)
            .then((id) => {
                let userService = new UserService(this.config);
                userService.getUserProfile(id)
                    .then(async (userProfile) => {
                        res.status(200);
                        res.send(JSON.stringify({
                            "success": true,
                            "text": "uspjesno",
                            "user": userProfile
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

export default RestUser;
