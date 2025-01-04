import DB from "../db/db.mjs";

class UserService {
    constructor(config) {
        this.config = config;
    }

    logInUser = async function(data) {
        if (!data.username) {
            throw new Error("Korisničko ime nije uneseno.");
        }

        if (!data.password) {
            throw new Error("Lozinka nije unesena.");
        }

        var db = new DB(this.config.dbConfig);
        await db.connect();
        let params = [data.username, data.password];
        let foundUsers = await db.execute("SELECT id, ime, prezime, korime, email FROM korisnik WHERE korime = $1 AND lozinka_hash = encode(sha256($2::bytea), 'hex');", params);
        await db.close();

        if (foundUsers == undefined || foundUsers == null || foundUsers.length != 1) {
            throw new Error("Korisnik s tim podacima ne postoji!");
        }

        let foundUser = foundUsers[0];

        return {
            user_id: foundUser.id,
            name: foundUser.ime,
            surname: foundUser.prezime,
            username: foundUser.korime,
            email: foundUser.email,
        };
    }

    registerUser = async function(data) {
        if (!data.name) {
            throw new Error("Ime nije uneseno.");
        }
        if (!data.surname) {
            throw new Error("Prezime nije uneseno.");
        }
        if (!data.username) {
            throw new Error("Korisničko ime nije uneseno.");
        }
        if (!data.email) {
            throw new Error("Email nije unesen.");
        }
        if (!data.password) {
            throw new Error("Lozinka nije unesena.");
        }

        var db = new DB(this.config.dbConfig);
        await db.connect();
        let params = [data.name, data.surname, data.username, data.email, data.password];
        try {
            await db.execute("SELECT registriraj_korisnika($1, $2, $3, $4, $5);", params);
        } catch (error) {
            throw error;
        } finally {
            await db.close();
        }
    }

    getUserProfile = async function(id) {
        if (!id) {
            throw new Error("Nije dan korisnikov ID.");
        }

        var db = new DB(this.config.dbConfig);
        await db.connect();
        let params = [id];
        let foundUsers = await db.execute("SELECT * FROM podaci_o_korisniku($1)", params);
        await db.close();

        if (!foundUsers || foundUsers.length != 1) {
            throw new Error("Korisnik s tim podacima ne postoji!");
        }

        let foundUser = foundUsers(0);

        console.log(foundUser);

        return foundUser;
    }
}

export default UserService;