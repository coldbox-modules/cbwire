component
    extends="cbwire.models.Component"
    accessors="true"
{

    property
        name="message"
        default="";

    function $renderIt(){
        return this.$renderView( "_wires/dataBinding" );
    }

}
