component extends="cbwire.models.Component" {

    variables.data = { "message" : "Hello World" };

    function $renderIt(){
        return this.$renderView( "_wires/helloWorldWithRenderViewPropertyAndArgs" );
    }

}
