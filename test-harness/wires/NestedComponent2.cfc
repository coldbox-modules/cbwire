component extends="cbwire.models.Component" {

    data = { "message" : "" };

    function saySomething(){
        data.message = "Something ( again )!";
    }

    function onRender(){
        return this.renderView( "wires/nestedComponent2" );
    }

}
