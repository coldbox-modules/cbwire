component extends="cbwire.models.Component" {

    variables.data = { "pizzaToppings" : [] };

    function renderIt(){
        return this.$renderView( "_wires/passParameters" );
    }

}
