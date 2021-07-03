component
    extends="cbwire.models.Component"
{

    this.$data = { "message" : "We have data binding!" };

    function $renderIt(){
        return this.$renderView( "_wires/dataBinding" );
    }

}
