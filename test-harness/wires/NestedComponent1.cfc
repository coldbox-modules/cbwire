component extends="cbwire.models.Component" {

    data = { "message" : "" };

    function saySomething(){
        data.message = "Something";
    }

    function onRender(){
        return this.renderView( "wires/nestedComponent1" );
    }

}
