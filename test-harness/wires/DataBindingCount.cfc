component
    extends="cbwire.models.Component"
    accessors="true"
{

    variables.data = { "count" : "0" };

    function increment(){
        variables.data.count += 1;
    }

    function $renderIt(){
        return this.$renderView( "_wires/dataBindingCount" );
    }

}
