component extends="cbLivewire.models.Component"{

    property name="message" default="";

    this.$listeners = {
        "someEvent": "someListener"
    };

    function someListener(){
        variables.message = "We have fired someListener() from a second listener!";
    }

    function $renderIt() {
        return this.$renderView( "_cblivewire/fireEvent" );
    }
}