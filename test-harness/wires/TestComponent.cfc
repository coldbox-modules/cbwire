component extends="cbwire.models.Component" {

    data = {
        "title": "CBWIRE Rocks!"
    };

    listeners = {
        "someEvent": "someListener"
    };

    function changeTitle() {
        data.title = "CBWIRE Slays!";
    }

    function resetTitle() {
        reset( "title" );
    }

    function someListener() {
        data.title = "Fired some event";
    }
}