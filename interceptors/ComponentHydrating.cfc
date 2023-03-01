component {

    property name="cbwireRequest" inject="CBWireRequest@cbwire";

    function onCBWireHydrate( event, rc, prc, data ){

        var cbwireComponent = data.component;

		var engine = cbwireComponent.getEngine();

        if ( variables.cbwireRequest.hasFingerprint() ) {
			cbwireComponent.getEngine().setId( variables.cbwireRequest.getFingerPrint()[ "id" ] );
		}

		engine.setBeforeHydrationState( duplicate( engine.getState() ) );

		if ( variables.cbwireRequest.hasData() ) {
			cbwireComponent.setData( variables.cbwireRequest.getData() );
		}

		// Check if our request contains a server memo, and if so update our component state.
		if ( variables.cbwireRequest.hasServerMemo() ) {
			var serverMemo = variables.cbwireRequest.getServerMemo();

			serverMemo.data.each( function( key, value ){
				if ( !isNull( arguments.value ) && isSimpleValue( arguments.value ) && findNoCase( "cbwire-upload:", arguments.value ) ) {
					var uuid = replaceNoCase( arguments.value, "cbwire-upload:", "", "once" );
					arguments.value = getController().getWireBox().getInstance( name="FileUpload@cbwire", initArguments={ comp=cbwireComponent, params=[ key, [ uuid  ] ] } );
				}
				engine.invokeMethod(
					methodName = "set" & arguments.key,
					value      = isNull( arguments.value ) ? "" : arguments.value
				);					

				if ( structKeyExists( cbwireComponent, "onHydrate#arguments.key#" ) ) {
					invoke( cbwireComponent, "onHydrate#arguments.key#", {
						data : engine.getDataProperties(),
						computed : engine.getComputedProperties()
					} );
				}
			} );

			if ( variables.cbwireRequest.hasChildren() ) {
				variables.$children = variables.cbwireRequest.getChildren();
			}
		}

		if ( structKeyExists( cbwireComponent, "onHydrate" ) ) {
			cbwireComponent.onHydrate(
				data=engine.getDataProperties(),
				computed=engine.getComputedProperties()
			);
		}

		// Check if our request contains updates, and if so apply them.
		if ( variables.cbwireRequest.hasUpdates() ) {
			variables.cbwireRequest.applyUpdates( cbwireComponent );
		}
    }
}