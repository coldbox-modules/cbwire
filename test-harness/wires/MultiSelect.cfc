component extends="cbwire.models.Component" {

    data = { "greeting" : "" };

    function renderIt(){
        return this.renderView( "_wires/multiselect" );
    }

}
