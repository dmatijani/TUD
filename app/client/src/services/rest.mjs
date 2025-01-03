class RestSender {
    constructor(url) {
        this.url = url;
    }

    sendRequest = async (method, path, body = undefined, authRequired = false) => {
        let headers = new Headers();
        headers.set("Content-Type", "application/json");
        
        let parameters = {
            credentials: "include",
            method: method,
            headers: headers
        }
        
        if (body != undefined && body != null) {
            parameters.body = JSON.stringify(body);
        }
        
        if (authRequired) {
            // TODO: pošalji JWT na link
            // TODO: dodaj to na fetch parameters
        }

        let response = await fetch(this.url + path, parameters);
        let data = JSON.parse(await response.text());
        data.status = response.status;
        data.headers = response.headers;

        return data;
    }
}

export default RestSender;