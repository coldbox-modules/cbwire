component {

    function onCBWireSubsequentRenderIt( event, data ){
        var component = data.component;	
        var engine = component.getEngine();
        component.set_IsInitialRendering( false );
		var result = component._getNoRendering() ? "" : engine.renderIt();
        event.setValue( "_cbwire_subsequent_rendering", trim( result ) );
	}
}