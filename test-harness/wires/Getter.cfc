component extends="cbwire.models.Component" {

    variables.$computed = { "name" : "Rubble on the double" };

    function mount(){
        variables.data.name = "Blah";
    }

    function renderIt(){
        return this.renderView( "_wires/getter" );
    }

}
