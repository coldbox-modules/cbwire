component extends="cbLivewire.models.Component"{

    property name="message" default="";

    function saySomething(){
        variables.message = "Something ( again )!";
    }

    function $renderIt(){
        return this.$renderView( "_cblivewire/nestedComponent2" );
    }
}