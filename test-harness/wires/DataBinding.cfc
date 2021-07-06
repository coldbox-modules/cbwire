component
    extends="cbwire.models.Component"
{

    variables.$data = { "message" : "We have data binding!" };

    function $renderIt(){
        return this.$renderView( "_wires/dataBinding" );
    }

}
