component
    extends="cbwire.models.Component"
{

    data = { "count" : 0 };

    function increment(){
        data.count += 1;
    }

    function renderIt(){
        return this.renderView( "_wires/dataBindingCount" );
    }

}
