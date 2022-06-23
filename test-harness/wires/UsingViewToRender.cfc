component extends="cbwire.models.Component" {

    data = { "message" : "Hello World" };

    function renderIt(){
        return this.renderView( "wires/helloWorldWithRenderViewPropertyAndArgs" );
    }

}
