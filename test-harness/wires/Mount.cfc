component
    extends="cbwire.models.Component"
    accessors="true"
{

    property
        name="message"
        default="Default value";

    function $mount(){
        setMessage( "Mounted value" );
    }

    function renderIt(){
        return this.$renderView( "_wires/mount" );
    }

}
