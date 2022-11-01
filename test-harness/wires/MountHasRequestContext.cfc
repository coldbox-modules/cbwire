component extends="cbwire.models.Component" {

    data = { "message" : "Default value" };

    function onMount( event, rc, prc ){
        var message = event.paramValue( "message", "Mounted value" );
        this.setMessage( event.getValue( "message" ) );
    }

    function renderIt(){
        return this.renderView( "wires/mount" );
    }

}
