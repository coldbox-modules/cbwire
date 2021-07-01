component
    extends="cbwire.models.Component"
    accessors="true"
{

    property
        name="pizzaToppings"
        default="";

    function $renderIt(){
        return this.$renderView( "_wires/passParameters" );
    }

}
