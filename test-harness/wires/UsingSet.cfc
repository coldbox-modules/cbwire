component
    extends="cbwire.models.Component"
    accessors="true"
{

    property
        name="name"
        default="Marty";

    function renderIt(){
        return this.renderView( "_wires/usingSet" );
    }

}
