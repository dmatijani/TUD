import fs from "fs/promises";

class Configuration {
    constructor(filepath) {
        this.filepath = filepath;
        this.conf = {};
    }

    getConf() {
        return this.conf;
    }

    async loadConfiguration() {
        let data = await fs.readFile(this.filepath, "UTF-8");
        this.conf = JSON.parse(data);
    }
}

export default Configuration;