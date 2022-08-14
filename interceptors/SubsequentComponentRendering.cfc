component {

    function onCBWireSubsequentRenderIt( event, data ){
        var component = data.component;	
        var engine = component.getEngine();
        engine.setIsInitialRendering( false );
		var result = engine.getNoRendering() ? "" : engine.renderIt();
        event.setValue( "_cbwire_subsequent_rendering", trim( result ) );
	}
}