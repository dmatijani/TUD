import AuthController from "./authController.mjs";

class RestSender {
    constructor() {
        this.url = window.restUrl;
    }

    sendRequest = async (method, path, body = undefined, authRequired = false, contentType = "application/json") => {
        let headers = new Headers();
    
        if (!(body instanceof FormData)) {
            headers.set("Content-Type", contentType);
        }
    
        let parameters = {
            credentials: "include",
            method: method,
        };
    
        if (body != undefined && body != null) {
            parameters.body = body instanceof FormData ? body : JSON.stringify(body);
        }
    
        if (authRequired) {
            let authController = new AuthController();
    
            let jwtResponse = await fetch(this.url + "/user/jwt", {
                method: "GET",
                credentials: "include"
            });
            let jwtResponseDataString = await jwtResponse.text();
            let jwtResponseData = JSON.parse(jwtResponseDataString);
            if (jwtResponse.status != 200) {
                authController.removeLoggedInUser();
                return {
                    success: false,
                    text: "Nije moguće dobiti JWT"
                };
            }
    
            let token = jwtResponseData.token;
            if (token == "" || token == null || token == undefined) {
                authController.removeLoggedInUser();
                return {
                    success: false,
                    text: "Nije moguće dobiti JWT"
                };
            }
    
            headers.set("Authorization", `Bearer ${token}`);
        }
    
        parameters.headers = headers;
    
        try {
            let response = await fetch(this.url + path, parameters);
            let data = JSON.parse(await response.text());
            data.status = response.status;
            data.headers = response.headers;
    
            return data;
        } catch (error) {
            return {
                success: false,
                error: `Greška tijekom HTTP zahtjeva: ${error.message}`
            };
        }
    };

    downloadFile = async (path, authRequired = false, fileName = "datoteka") => {
        let headers = new Headers();
    
        if (authRequired) {
            let authController = new AuthController();
    
            let jwtResponse = await fetch(this.url + "/user/jwt", {
                method: "GET",
                credentials: "include"
            });
            let jwtResponseDataString = await jwtResponse.text();
            let jwtResponseData = JSON.parse(jwtResponseDataString);
            if (jwtResponse.status != 200) {
                authController.removeLoggedInUser();
                return {
                    success: false,
                    text: "Nije moguće dobiti JWT"
                };
            }
    
            let token = jwtResponseData.token;
            if (token == "" || token == null || token == undefined) {
                authController.removeLoggedInUser();
                return {
                    success: false,
                    text: "Nije moguće dobiti JWT"
                };
            }
    
            headers.set("Authorization", `Bearer ${token}`);
        }
    
        try {
            let response = await fetch(this.url + path, {
                headers: headers,
                credentials: "include",
                method: "GET",
            });
    
            if (!response.ok) {
                return { 
                    success: false,
                    error: "Greška prilikom preuzimanja datoteke."
                 };
            }
    
            let contentDisposition = response.headers.get("Content-Disposition");
            
            if (contentDisposition && contentDisposition.includes("filename=")) {
                fileName = contentDisposition.split("filename=")[1].replace(/"/g, "");
            }
    
            let blob = await response.blob();
            let url = window.URL.createObjectURL(blob);
    
            let a = document.createElement("a");
            a.href = url;
            a.download = fileName;
            document.body.appendChild(a);
            a.click();
            a.remove();
            window.URL.revokeObjectURL(url);
    
            return { success: true, fileName };
        } catch (error) {
            console.error("Greška tijekom preuzimanja datoteke: ", error);
            return { success: false, error: error.message };
        }
    };
    
}

export default RestSender;