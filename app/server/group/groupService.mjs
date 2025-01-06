import DB from "../db/db.mjs";

class GroupService {
    constructor(config) {
        this.config = config;
    }

    getGroupDetails = async function(id, userId) {
        if (!id) {
            throw new Error("Nije dan ID grupe.");
        }

        var db = new DB(this.config.dbConfig);
        await db.connect();
        let params = [id, userId];
        let foundGroups = null;
        try {
            foundGroups = await db.execute("SELECT * FROM podaci_o_grupi($1, $2)", params);
        } catch (error) {
            throw error;
        } finally {
            await db.close();
        }

        if (!foundGroups || foundGroups.length != 1) {
            throw new Error("Grupa s tim podacima ne postoji!");
        }

        let foundGroup = foundGroups[0];

        return foundGroup;
    }

    addMemberToGroup = async function(memberId, groupId, ownerId) {
        if (!memberId) {
            throw new Error("Nije dan ID grupe.");
        }

        if (!groupId) {
            throw new Error("Nije dan ID člana.");
        }

        var db = new DB(this.config.dbConfig);
        await db.connect();
        let params = [ownerId, groupId, memberId];
        try {
            await db.execute("SELECT dodaj_clana_u_grupu($1, $2, $3);", params);
        } catch (error) {
            throw error;
        } finally {
            await db.close();
        }
    }

    removeMemberFromGroup = async function(memberId, groupId, ownerId) {
        if (!memberId) {
            throw new Error("Nije dan ID grupe.");
        }

        if (!groupId) {
            throw new Error("Nije dan ID člana.");
        }

        var db = new DB(this.config.dbConfig);
        await db.connect();
        let params = [ownerId, groupId, memberId];
        try {
            await db.execute("SELECT ukloni_clana_iz_grupe($1, $2, $3);", params);
        } catch (error) {
            throw error;
        } finally {
            await db.close();
        }
    }

    createGroup = async function(groupName, creatorId) {
        if (!groupName) {
            throw new Error("Nije dan naziv grupe.");
        }

        var db = new DB(this.config.dbConfig);
        await db.connect();
        let params = [groupName, creatorId];
        try {
            await db.execute("SELECT stvori_grupu($1, $2);", params);
        } catch (error) {
            throw error;
        } finally {
            await db.close();
        }
    }
}

export default GroupService;