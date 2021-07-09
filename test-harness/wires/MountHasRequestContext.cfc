component extends="cbwire.models.Component" {

    variables.data = { "message" : "Default value" };

    function mount( event, rc, prc ){
        var message = event.paramValue( "message", "Mounted value" );
        this.setMessage( event.getValue( "message" ) );
    }

    function renderIt(){
        return this.renderView( "_wires/mount" );
    }

}
