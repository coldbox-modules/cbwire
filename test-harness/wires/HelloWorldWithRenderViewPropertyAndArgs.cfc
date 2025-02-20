component extends="cbwire.models.Component" {

    data = { "message" : "Hello world" };

    function onRender(){
        return this.view( "wires/helloWorldWithRenderViewPropertyAndArgs" );
    }

}
