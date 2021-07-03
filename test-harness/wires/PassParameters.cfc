component
    extends="cbwire.models.Component"
{

    this.$data = {
        "pizzaToppings": []
    };

    function $renderIt(){
        return this.$renderView( "_wires/passParameters" );
    }

}
