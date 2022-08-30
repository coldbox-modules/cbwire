component extends="cbwire.models.Component" {

    data = {
        "message": ""
    };

    function callAction(){
        data.message = "We have called our action!";
    }

}
