component extends="cbwire.models.Component" {

    variables.data = { "message" : "Hello world" };

    function $renderIt(){
        return this.$renderView( "_wires/helloWorldWithRenderViewPropertyAndArgs" );
    }

}
