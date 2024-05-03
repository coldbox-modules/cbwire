component extends="cbwire.models.Component" {

    data = {
        "name": "",
        "zip": "",
        "email": "",
        "submitted": false
    };

    constraints = {
        "name": { "required": true }
    };

    function submitForm() {
        validateOrFail();
        data.submitted = true;
    }

    function resetForm() {
        reset();
        data.submitted = false;
    }
}