component {
    
    function onCBWireHydrate( event, rc, prc, data ){

		var cbwireRequest = getInstance( "CBWireRequest@cbwire" );

        var cbwireComponent = data.component;

		var engine = cbwireComponent.getEngine();

        if ( cbwireRequest.hasFingerprint() ) {
			cbwireComponent.set_id( cbwireRequest.getFingerPrint()[ "id" ] );
		}

		engine.setBeforeHydrationState( duplicate( cbwireComponent._getState() ) );

		if ( cbwireRequest.hasData() ) {
			cbwireComponent.setData( cbwireRequest.getData() );
		}

		// Check if our request contains a server memo, and if so update our component state.
		if ( cbwireRequest.hasServerMemo() ) {
			var serverMemo = cbwireRequest.getServerMemo();

			serverMemo.data.each( function( key, value ){
				if ( !isNull( arguments.value ) && isSimpleValue( arguments.value ) && findNoCase( "cbwire-upload:", arguments.value ) ) {
					var uuid = replaceNoCase( arguments.value, "cbwire-upload:", "", "once" );
					arguments.value = getController().getWireBox().getInstance( name="FileUpload@cbwire", initArguments={ comp=cbwireComponent, params=[ key, [ uuid  ] ] } );
				}
				cbwireComponent._invokeMethod(
					methodName = "set" & arguments.key,
					value      = isNull( arguments.value ) ? "" : arguments.value
				);					

				if ( structKeyExists( cbwireComponent, "onHydrate#arguments.key#" ) ) {
					invoke( cbwireComponent, "onHydrate#arguments.key#", {
						data : engine.getDataProperties(),
						computed : cbwireComponent._getComputedProperties()
					} );
				}
			} );

			if ( cbwireRequest.hasChildren() ) {
				variables.$children = cbwireRequest.getChildren();
			}
		}

		if ( structKeyExists( cbwireComponent, "onHydrate" ) ) {
			cbwireComponent.onHydrate(
				data=engine.getDataProperties(),
				computed=cbwireComponent._getComputedProperties()
			);
		}

		// Check if our request contains updates, and if so apply them.
		if ( cbwireRequest.hasUpdates() ) {
			cbwireRequest.applyUpdates( comp=cbwireComponent );
		}
    }
}