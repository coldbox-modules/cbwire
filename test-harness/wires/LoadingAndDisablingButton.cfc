component extends="cbwire.models.Component" {

    function checkout(){
        sleep( 5000 );
    }

    function renderIt(){
        return this.renderView( "wires/loadingAndDisablingButton" );
    }

}
