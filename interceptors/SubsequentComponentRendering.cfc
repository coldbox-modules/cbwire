component {

    function onCBWireSubsequentRenderIt( event, data ){
        var component = data.component;	
        component.set_IsInitialRendering( false );
		var result = component._getNoRendering() ? "" : component._renderIt();
        event.setValue( "_cbwire_subsequent_rendering", trim( result ) );
	}
}