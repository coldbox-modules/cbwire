component extends="cbwire.models.Component" {

    data = { "message" : "Hello world" };

    function renderIt(){
        return this.view( "_wires/helloWorldWithRenderViewPropertyAndArgs" );
    }

}
