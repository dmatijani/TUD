import DB from "../db/db.mjs";

class RoleService {
    constructor(config) {
        this.config = config;
    }

    getRoles = async function() {
        var db = new DB(this.config.dbConfig);
        await db.connect();
        let roles = [];
        try {
            roles = await db.execute("SELECT unnest(enum_range(NULL::pravo)) AS pravo;");
        } catch (error) {
            throw error;
        } finally {
            await db.close();
        }

        return roles;
    }
}

export default RoleService;