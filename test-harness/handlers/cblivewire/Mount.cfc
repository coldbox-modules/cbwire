component extends="cblivewire.core.Component" accessors="true" {

    property name="message" default="Default value";

    function mount() {
        setMessage( "Mounted value" );
    }

    function render() {
        return renderView( "_cblivewire/mount" );
    }
}