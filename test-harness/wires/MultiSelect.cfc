component extends="cbwire.models.Component" {

    this.$data = {
        "greeting": ""
    };

    function $renderIt(){
        return this.$renderView( "_wires/multiselect" );
    }

}
