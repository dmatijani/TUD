import DB from "../db/db.mjs";

class UserService {
    constructor(config) {
        this.config = config;
    }

    getUserData = async function(id) {
        if (id == null || id == undefined) {
            throw new Error("Nije dan korisnikov ID.");
        }

        var db = new DB(this.config.dbConfig);
        await db.connect();
        let params = [id];
        let foundUsers = await db.execute("SELECT id, ime, prezime, korime, email FROM korisnik WHERE id = $1;", params);
        await db.close();

        if (foundUsers == undefined || foundUsers == null || foundUsers.length != 1) {
            throw new Error("Korisnik s tim podacima ne postoji!");
        }

        let foundUser = foundUsers[0];

        return {
            "user_id": foundUser.id,
            "name": foundUser.ime,
            "surname": foundUser.prezime,
            "username": foundUser.korime,
            "email": foundUser.email,
        };
    }

    logInUser = async function(data) {
        if (data.username == "" || data.username == null || data.username == undefined) {
            throw new Error("Korisničko ime nije uneseno.");
        }

        if (data.password == "" || data.password == null || data.password == undefined) {
            throw new Error("Lozinka nije unesena.");
        }

        var db = new DB(this.config.dbConfig);
        await db.connect();
        let params = [data.username, data.password];
        let foundUsers = await db.execute("SELECT id, ime, prezime, korime, email FROM korisnik WHERE korime = $1 AND lozinka_hash = encode(sha256($2), 'hex');", params);
        await db.close();

        if (foundUsers == undefined || foundUsers == null || foundUsers.length != 1) {
            throw new Error("Korisnik s tim podacima ne postoji!");
        }

        let foundUser = foundUsers[0];

        return {
            "user_id": foundUser.id,
            "name": foundUser.ime,
            "surname": foundUser.prezime,
            "username": foundUser.korime,
            "email": foundUser.email,
        };
    }
}

export default UserService;