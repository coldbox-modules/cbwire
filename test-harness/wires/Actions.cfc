component extends="cbwire.models.Component" {

    data = {
        "result": "No actions have ran"
    };

    function action1() {
        data.result = "Action ##1 ran!";
    }

    function action2() {
        data.result = "Action ##2 ran!";
    }

    function action3( actionName ) {
        data.result = "#actionName# ran and passed parameters!";
    }
}