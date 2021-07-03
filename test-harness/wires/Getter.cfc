component
    extends="cbwire.models.Component"
{

    this.$computed = {
        "name": "Rubble on the double"
    };

    function $mount(){
        this.$data.name = "Blah";
    }

    function $renderIt(){
        return this.$renderView( "_wires/getter" );
    }

}
