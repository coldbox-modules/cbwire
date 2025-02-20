component extends="cbwire.models.Component" {

    data.message = "";

    listeners = { "someEvent" : "someListener" };

    function someAction(){
        this.emit( "someEvent" );
    }

    function someListener(){
        data.message = "We have fired someListener() using this.emit in our component!";
    }

    function onRender(){
        return this.renderView( "wires/fireEvent" );
    }

}
