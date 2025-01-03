class AuthController {
    saveLoggedInUser = (user) => {
        sessionStorage["user"] = JSON.stringify(user);
    }

    removeLoggedInUser = () => {
        sessionStorage.clear();
    }

    getLoggedInUser = () => {
        let user = sessionStorage["user"];

        if (user == undefined) {
            return {};
        }

        return JSON.parse(user);
    }

    isAuthenticated = () => {
        return sessionStorage["user"] != undefined;
    }
}

export default AuthController;