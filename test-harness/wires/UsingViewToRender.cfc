component extends="cbwire.models.Component" {

    this.$data = { "message" : "Hello World" };

    function $renderIt(){
        return this.$view( "_wires/helloWorldWithRenderViewPropertyAndArgs" );
    }

}
