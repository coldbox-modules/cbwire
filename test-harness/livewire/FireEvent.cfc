component extends="cbLivewire.models.Component"{

    property name="message" default="";

    this.$listeners = {
        "someEvent": "someEvent"
    };

    function someEvent(){
        variables.message = "We have fired someEvent()!";
    }

    function $renderIt() {
        return this.$renderView( "_cblivewire/fireEvent" );
    }
}