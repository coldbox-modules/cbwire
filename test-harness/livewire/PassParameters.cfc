component extends="cbLivewire.models.Component" accessors="true" {

    property name="pizzaToppings";

    function $renderIt() {
        return this.$renderView( "_cblivewire/passParameters" );
    }
}