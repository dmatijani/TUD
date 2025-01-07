import DB from "../db/db.mjs";

class TypeService {
    constructor(config) {
        this.config = config;
    }

    getTypes = async function() {
        var db = new DB(this.config.dbConfig);
        await db.connect();
        let types = [];
        try {
            types = await db.execute("SELECT unnest(enum_range(NULL::vrsta_dokumenta)) AS vrijednost;");
        } catch (error) {
            throw error;
        } finally {
            await db.close();
        }

        return types;
    }
}

export default TypeService;