component extends="cbLivewire.models.Component" {

    function $mount(
        parameters,
        event,
        rc,
        prc
    ){
        variables.pizzaToppings = arguments.parameters.otherPizzaToppings;
    }

    function $renderIt(){
        return this.$renderView( "_cblivewire/passParameters" );
    }

}
