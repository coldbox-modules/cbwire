component extends="cbwire.models.Component" {

    function $mount( parameters, event, rc, prc ){
        variables.pizzaToppings = arguments.parameters.otherPizzaToppings;
    }

    function $renderIt(){
        return this.$renderView( "_wires/passParameters" );
    }

}
