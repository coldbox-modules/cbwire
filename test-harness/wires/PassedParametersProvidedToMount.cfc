component extends="cbwire.models.Component" {

    data = {
        "pizzaToppings": ""
    };

    function onMount( parameters, event, rc, prc ){
        data.pizzaToppings = arguments.parameters.otherPizzaToppings;
    }
}
