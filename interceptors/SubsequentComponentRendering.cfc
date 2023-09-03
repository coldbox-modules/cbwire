component {

    function onCBWireSubsequentRenderIt( event, data ){
        var component = data.component;	
        component.setIsInitialRendering( false );
		var result = component.getNoRendering() ? "" : component.renderIt();
        event.setValue( "_cbwire_subsequent_rendering", trim( result ) );
	}
}