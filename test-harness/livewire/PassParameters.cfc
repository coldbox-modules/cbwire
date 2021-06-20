component extends="cbLivewire.models.Component" accessors="true" {

    property name="pizzaToppings" default="";

    function $renderIt() {
        return this.$renderView( "_cblivewire/passParameters" );
    }
}