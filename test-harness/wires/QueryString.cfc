component extends="cbwire.models.Component" {


    this.$data = {
        "search": ""
    };

    this.$queryString = [ "search" ];

    function $renderIt(){
        return this.$renderView( "_wires/queryString" );
    }

}
