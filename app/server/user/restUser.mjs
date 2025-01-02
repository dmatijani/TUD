import UserService from "./userService.mjs";

class RestUser {
    constructor() {}

    postUserLogin = (req, res) => {
    res.type("application/json");

    let userService = new UserService();

    let body = req.body;
    userService.logInUser(body)
        .then(async (user) => {
            res.status(201);
            // TODO: JWT header
            res.send(JSON.stringify({
                "success": true,
                "text": "uspjesno",
                "username": user.username
            }));
        })
        .catch((error) => {
            res.status(400);
            res.send(JSON.stringify({
                "success": false,
                "error": error
            }));
        })
    };
}

export default RestUser;
