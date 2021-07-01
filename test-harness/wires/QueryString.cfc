component extends="cbwire.models.Component" {

    property
        name="search"
        default="";

    this.$queryString = [ "search" ];

    function $renderIt(){
        return this.$renderView( "_cbwire/queryString" );
    }

}
