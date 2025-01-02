import UserService from "./userService.mjs";

class RestUser {
    constructor(config) {
        this.config = config;
    }

    postUserLogin = (req, res) => {
    res.type("application/json");

    let userService = new UserService(this.config);

    let body = req.body;
    userService.logInUser(body)
        .then(async (user) => {
            res.status(201);
            console.log("USER: ");
            console.log(user);
            // TODO: JWT header
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
        })
    };
}

export default RestUser;
