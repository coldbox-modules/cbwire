component
    extends="cbwire.models.Component"
    accessors="true"
{

    property
        name="message"
        default="Hello World";

    function $renderIt(){
        return this.$view( "_wires/helloWorldWithRenderViewPropertyAndArgs" );
    }

}
