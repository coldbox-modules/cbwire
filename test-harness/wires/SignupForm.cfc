component extends="cbwire.models.Component" {

    data = {
        "name": "",
        "email": "",
        "zip": "",
        "submitted": false
    };

    function submitForm() {
        data.submitted = true;
    }
}