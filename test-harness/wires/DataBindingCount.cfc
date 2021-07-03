component
    extends="cbwire.models.Component"
    accessors="true"
{

    this.$data = { "count" : "0" };

    function increment(){
        this.$data.count += 1;
    }

    function $renderIt(){
        return this.$renderView( "_wires/dataBindingCount" );
    }

}
