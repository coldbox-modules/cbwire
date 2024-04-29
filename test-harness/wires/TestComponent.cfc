component extends="cbwire.models.v4.Component" {

    data = {
        "title": "CBWIRE Rocks!"
    };

    listeners = {
        "someEvent": "someListener"
    };

    function runJSMethod(){
        js( "alert('Hello from CBWIRE!');" );
        js( "console.log('Hello from CBWIRE!');" );
    }

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