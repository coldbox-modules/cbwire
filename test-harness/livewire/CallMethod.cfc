component extends="cbLivewire.models.Component" accessors="true" {

    property name="message" default="";

    function calledMethod(){
        variables.message = "We have called our method!";
    }

    function $renderIt() {
        return this.$renderView( "_cblivewire/callMethod" );
    }
}