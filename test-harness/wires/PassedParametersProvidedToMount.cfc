component extends="cbwire.models.Component" {
    function onMount( parameters, event, rc, prc ){
        data.pizzaToppings = arguments.parameters.otherPizzaToppings;
    }
}
