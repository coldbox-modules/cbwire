component extends="cbwire.models.Component" {

    variables.data = { "search" : "" };

    variables.queryString = [ "search" ];


    function mount( event ){
        variables.data[ "search" ] = event.getValue( "search", "" );

    }
    function renderIt(){
        return this.renderView( "_wires/queryString" );
    }

}
