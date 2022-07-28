component {

    function onCBWireSubsequentRenderIt( event, data ){
        var component = data.component;	
		var result = component.getEngine().getNoRendering() ? "" : component.getEngine().renderIt();
        event.setValue( "_cbwire_subsequent_rendering", trim( result ) );
	}
}