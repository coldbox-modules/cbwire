component extends="cblivewire.core.Component" accessors="true" {

    property name="name" default="Marty";

    function resetName( otherName ) {
        setName( otherName );
    }

    function render() {
        return renderView( "_cblivewire/passMethodArgs" );
    }
}