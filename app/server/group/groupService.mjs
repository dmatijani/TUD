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
}

export default GroupService;