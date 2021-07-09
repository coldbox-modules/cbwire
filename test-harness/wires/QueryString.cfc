component extends="cbwire.models.Component" {

    variables.data = { "search" : "" };

    variables.$queryString = [ "search" ];

    function renderIt(){
        return this.renderView( "_wires/queryString" );
    }

}
