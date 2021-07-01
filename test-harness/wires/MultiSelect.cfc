component extends="cbwire.models.Component" {

    property
        name="greeting"
        default="";

    function $renderIt(){
        return this.$renderView( "_wires/multiselect" );
    }

}
