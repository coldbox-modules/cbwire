component extends="cbLivewire.models.Component" accessors="true" {

    property name="pizzaToppings";

    function renderIt() {
        return renderView( "_cblivewire/passParameters" );
    }
}