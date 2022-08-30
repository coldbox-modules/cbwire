component {

    function onCBWireRenderIt( required event, required data ){
        var cbwireComponent = data.component;
		var componentName = lCase( getMetadata( cbwireComponent ).name );
        event.setValue( "_cbwire_rendering", cbwireComponent.view( view="wires/#listLast( componentName, "." )#" ) );
        event.setValue( "_cbwire_rendering_raw", cbwireComponent.view( view="wires/#listLast( componentName, "." )#", applyWiring=false ) );
    }

}