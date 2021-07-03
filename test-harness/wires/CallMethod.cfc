component
    extends="cbwire.models.Component"
{

    function $mount(){
        this.$data.message = "default";
    }

    function calledMethod(){
        this.$data.message = "We have called our method!";
    }

    function $renderIt(){
        return this.$renderView( "_wires/callMethod" );
    }

}
