import DB from "../db/db.mjs";

class UserService {
    constructor(config) {
        this.config = config;
    }

    getUserData = async function(id) {
        if (!id) {
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
            userId: foundUser.id,
            name: foundUser.ime,
            surname: foundUser.prezime,
            username: foundUser.korime,
            email: foundUser.email,
        };
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
            userId: foundUser.id,
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
        if (!data.address) {
            data.address = "";
        }
        if (!data.phone) {
            data.phone = "";
        }

        var db = new DB(this.config.dbConfig);
        await db.connect();
        let params = [data.name, data.surname, data.username, data.email, data.password, data.address, data.phone];
        try {
            await db.execute("SELECT registriraj_korisnika($1, $2, $3, $4, $5, $6, $7);", params);
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

        let foundUser = foundUsers[0];

        return foundUser;
    }

    getUsersNotInGroup = async function(groupId, ownerId) {
        if (!groupId) {
            throw new Error("Nije dan ID grupe.");
        }

        var db = new DB(this.config.dbConfig);
        await db.connect();
        let params = [ownerId, groupId];
        let foundUsers = await db.execute("SELECT * FROM korisnici_koji_nisu_clanovi_grupe($1, $2)", params);
        await db.close();

        if (!foundUsers) {
            throw new Error("Korisnik s tim podacima ne postoji!");
        }

        return foundUsers;
    }

    getAllUsers = async function() {
        var db = new DB(this.config.dbConfig);
        await db.connect();
        try {
            return await db.execute("SELECT k.id, CONCAT(k.ime, ' ', k.prezime) AS naziv FROM korisnik k;");
        } catch (error) {
            throw error;
        } finally {
            await db.close();
        }
    }
}

export default UserService;