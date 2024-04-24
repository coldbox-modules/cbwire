component extends="cbwire.models.v4.Component" {

    data = { "search" : "" };

    queryString = [ "search" ];


    function onMount( event ){
        data[ "search" ] = event.getValue( "search", "" );
    }

    function renderIt(){
        return view( "wires.queryString" );
    }

}
