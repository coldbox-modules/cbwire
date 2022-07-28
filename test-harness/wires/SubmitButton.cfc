component extends="cbwire.models.Component" {

    data = {
        "message": ""
    };

    function clickButton() {
        data.message = "Form submit button was clicked!";
    }
}
