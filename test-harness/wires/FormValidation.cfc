component extends="cbwire.models.Component" {

    this.constraints = {
        "email": { required: true, type: "email" }
    };

    data = {
        "email": "",
        "success": false
    };

    function addEmail() {
        validateOrFail();
        data.success = true;
    }
}