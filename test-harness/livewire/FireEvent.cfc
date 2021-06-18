component extends="cbLivewire.models.Component"{

    property name="message" default="";

    this.$listeners = {
        "someEvent": "someListener"
    };

    function someListener(){
        variables.message = "We have fired someListener()!";
    }

    function $renderIt() {
        return this.$renderView( "_cblivewire/fireEvent" );
    }
}