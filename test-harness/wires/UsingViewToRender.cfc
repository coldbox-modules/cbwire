component extends="cbwire.models.Component" {

    this.$data = { "message" : "Hello World" };

    function $renderIt(){
        return this.$renderView( "_wires/helloWorldWithRenderViewPropertyAndArgs" );
    }

}
