component extends="cblivewire.core.Component" accessors="true" {

    property name="message" default="Hello World";

    function render() {
        return renderView( "_cblivewire/hello_world_with_render_view" );
    }
}