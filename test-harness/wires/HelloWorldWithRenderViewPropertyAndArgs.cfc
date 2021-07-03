component extends="cbwire.models.Component" {

    this.$data = { "message" : "Hello world" };

    function $renderIt(){
        return this.$renderView( "_wires/helloWorldWithRenderViewPropertyAndArgs" );
    }

}
