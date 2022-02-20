component extends="cbwire.models.Component" {

    data = { "message" : "test" };

    listeners = { "someOtherEvent" : "someListener" };

    function someListener(){
        data.message = "We have fired someListener() from a listener!";
    }

    function someAction(){
        this.emit( "someOtherEvent", [ "grant", "allen", "copley" ] );
    }

    function renderIt(){
        return this.renderView( "_wires/fireEvent" );
    }

}
