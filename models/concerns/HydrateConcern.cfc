component accessors="true" singleton {

	property name="cbwireService" inject="CBWIREService@cbwire";
	property name="wirebox" inject="wirebox";

	function handle( comp ){
		var rendererComponent = arguments.comp;

		if ( rendererComponent.hasFingerprint() ) {
			rendererComponent.setID( rendererComponent.getFingerPrint()[ "id" ] );
		}

		rendererComponent.setBeforeHydrationState( duplicate( rendererComponent.getState() ) );

		if ( rendererComponent.hasServerMemoData() ) {
			rendererComponent
				.getDataProperties()
				.each( function( key, value ){
					if ( structKeyExists( rendererComponent.getServerMemoData(), key ) ) {
						rendererComponent.getDataProperties()[ key ] = rendererComponent.getServerMemoData()[ key ];
					}
				} );
		}

		// Check if our request contains a server memo, and if so update our component state.
		if ( rendererComponent.hasServerMemo() ) {
			var serverMemo = rendererComponent.getServerMemo();

			serverMemo.data.each( function( key, value ){
				if (
					!isNull( arguments.value ) && isSimpleValue( arguments.value ) && findNoCase(
						"cbwire-upload:",
						arguments.value
					)
				) {
					var uploadFullReference = duplicate( arguments.value );
					var uuid = replaceNoCase( arguments.value, "cbwire-upload:", "", "once" );
					arguments.value = getWireBox().getInstance(
						name = "FileUpload@cbwire",
						initArguments = {
							comp : rendererComponent,
							params : [ key, [ uuid ] ]
						}
					);
				}

				rendererComponent.setProperty( arguments.key, isNull( arguments.value ) ? "" : arguments.value );

				if ( structKeyExists( rendererComponent.getParent(), "onHydrate#arguments.key#" ) ) {
					invoke(
						rendererComponent.getParent(),
						"onHydrate#arguments.key#",
						{
							value : arguments.value,
							data : rendererComponent.getDataProperties(),
							computed : rendererComponent.getComputedProperties()
						}
					);
				}
			} );
		}

		if ( structKeyExists( rendererComponent.getParent(), "onHydrate" ) ) {
			rendererComponent
				.getParent()
				.onHydrate(
					data = rendererComponent.getDataProperties(),
					computed = rendererComponent.getComputedProperties()
				);
		}

		// Check if our request contains updates, and if so apply them.
		getCBWIREService().getConcern( "ApplyUpdates" ).handle( comp = rendererComponent );
	}

}
