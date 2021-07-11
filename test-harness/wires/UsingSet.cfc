component
    extends="cbwire.models.Component"
    accessors="true"
{

    variables.data = {
        "name": "Marty"
    };

    function renderIt(){
        return this.renderView( "_wires/usingSet" );
    }

}
