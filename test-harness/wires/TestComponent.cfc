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

    function resetAll() {
        reset();
    }

    function someListener() {
        data.title = "Fired some event";
    }

    function performRedirect() {
        relocate( event="main.index" );
    }
}