component extends="cbwire.models.Component" {


    data = {
        "message": "test"
    };

    listeners = { "someEvent" : "someListener" };

    function someAction(){
        this.emit( "someEvent" );
    }

    function someListener(){
        data.message = "We have fired someListener() from a second listener!";
    }

    function onRender(){
        return this.renderView( "wires/fireEvent" );
    }

}
