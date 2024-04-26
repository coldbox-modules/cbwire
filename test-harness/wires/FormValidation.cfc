component extends="cbwire.models.v4.Component" {

    constraints = {
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