component extends="cbwire.models.Component" {

    data = { "search" : "" };

    queryString = [ "search" ];


    function mount( event ){
        data[ "search" ] = event.getValue( "search", "" );

    }
    function renderIt(){
        return this.renderView( "wires/queryString" );
    }

}
