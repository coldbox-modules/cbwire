component extends="cbwire.models.Component" {

    function checkout(){
        sleep( 5000 );
    }

    function onRender(){
        return this.renderView( "wires/loading" );
    }

}
