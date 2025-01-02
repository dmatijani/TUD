class UserService {
    constructor() {

    }

    logInUser = async function(data) {
        if (data.username == "" || data.username == null || data.username == undefined) {
            throw new Error("Korisničko ime nije uneseno.");
        }

        if (data.password == "" || data.password == null || data.password == undefined) {
            throw new Error("Lozinka nije unesena.");
        }

        return {
            "username": data.username
        };
    }
}

export default UserService;