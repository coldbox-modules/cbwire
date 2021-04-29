component extends="cbLivewire.models.Component" {

    property name="pizzaToppings";

    function getPizzaToppings() {
        return variables.pizzaToppings;
    }

    function renderIt() {
        return renderView( "_cblivewire/passParameters" );
    }
}