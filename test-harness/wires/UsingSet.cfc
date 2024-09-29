component
    extends="cbwire.models.Component"
    accessors="true"
{

    data = {
        "name": "Marty"
    };

    function onRender(){
        return this.renderView( "wires/usingSet" );
    }

}
