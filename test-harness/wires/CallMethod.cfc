component
    extends="cbwire.models.Component"
    accessors="true"
{

    function $mount(){
        variables.message = "default";
    }

    function calledMethod(){
        variables.message = "We have called our method!";
    }

    function $renderIt(){
        return this.$renderView( "_wires/callMethod" );
    }

}
