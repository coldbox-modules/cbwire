component accessors="true" singleton {

	property name="cbwireService" inject="CBWIREService@cbwire";
	property name="wirebox" inject="wirebox";

	function handle( comp ){
		var localComponent = arguments.comp;

		if ( localComponent.hasFingerprint() ) {
			localComponent.setID( localComponent.getFingerPrint()[ "id" ] );
		}

		localComponent.setBeforeHydrationState( duplicate( localComponent.getState() ) );

		if ( localComponent.hasServerMemoData() ) {
			localComponent
				.getDataProperties()
				.each( function( key, value ){
					if ( structKeyExists( localComponent.getServerMemoData(), key ) ) {
						localComponent.getDataProperties()[ key ] = localComponent.getServerMemoData()[ key ];
					}
				} );
		}

		// Check if our request contains a server memo, and if so update our component state.
		if ( localComponent.hasServerMemo() ) {
			var serverMemo = localComponent.getServerMemo();

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
							comp : localComponent,
							params : [ key, [ uuid ] ]
						}
					);
				}

				localComponent.setProperty( arguments.key, isNull( arguments.value ) ? "" : arguments.value );

				if ( structKeyExists( localComponent.getParent(), "onHydrate#arguments.key#" ) ) {
					invoke(
						localComponent.getParent(),
						"onHydrate#arguments.key#",
						{
							value : arguments.value,
							data : localComponent.getDataProperties(),
							computed : localComponent.getComputedProperties()
						}
					);
				}
			} );
		}

		if ( structKeyExists( localComponent.getParent(), "onHydrate" ) ) {
			localComponent
				.getParent()
				.onHydrate(
					data = localComponent.getDataProperties(),
					computed = localComponent.getComputedProperties()
				);
		}

		// Check if our request contains updates, and if so apply them.
		getCBWIREService().getConcern( "ApplyUpdates" ).handle( comp = localComponent );
	}

}
