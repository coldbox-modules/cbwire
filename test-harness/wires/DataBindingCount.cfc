component
    extends="cbwire.models.Component"
    accessors="true"
{

    property
        name="count"
        default="0";

    function increment(){
        variables.count += 1;
    }

    function $renderIt(){
        return this.$renderView( "_wires/dataBindingCount" );
    }

}
