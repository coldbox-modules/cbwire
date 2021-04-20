component extends="cblivewire.core.Component" {

    property name="message" default="Hello";

    function render() {
        return renderView( "_cblivewire/dataBinding" );
    }
}