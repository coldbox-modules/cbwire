component extends="cblivewire.core.Component" accessors="true" {

    property name="name" default="Marty";

    function render() {
        return renderView( "_cblivewire/usingSet" );
    }
}