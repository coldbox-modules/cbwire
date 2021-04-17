component extends="cblivewire.core.Component" accessors="true" {

    property name="count" default="0";

    function increment() {
        variables.count += 1;
    }

    function render() {
        return renderView( "_cblivewire/dataBindingCount" );
    }
}