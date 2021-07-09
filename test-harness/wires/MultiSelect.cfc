component extends="cbwire.models.Component" {

    variables.data = { "greeting" : "" };

    function $renderIt(){
        return this.$renderView( "_wires/multiselect" );
    }

}
