component extends="cbwire.models.v4.Component" {

    data = {
        "message": ""
    };

    function clickButton() {
        data.message = "Form submit button was clicked!";
    }
}
