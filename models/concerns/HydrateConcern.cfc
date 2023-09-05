component accessors="true" singleton {

    property name="cbwireService" inject="CBWIREService@cbwire";
    property name="wirebox" inject="wirebox";

    function handle( comp ) {
        var cbwireRequest = wirebox.getInstance( "CBWireRequest@cbwire" );

        if ( comp.hasFingerprint() ) {
			comp.setID( comp.getFingerPrint()[ "id" ] );
		}

		comp.setBeforeHydrationState( duplicate( comp.getState() ) );

		if ( comp.hasServerMemoData() ) {
			comp.getDataProperties().each( function( key, value ) {
				if ( structKeyExists( comp.getServerMemoData(), key ) ) {
					comp.getDataProperties()[ key ] = comp.getServerMemoData()[ key ];
				}
			} );
		}

		// Check if our request contains a server memo, and if so update our component state.
		if ( comp.hasServerMemo() ) {
			var serverMemo = comp.getServerMemo();

			serverMemo.data.each( function( key, value ){
				if ( !isNull( arguments.value ) && isSimpleValue( arguments.value ) && findNoCase( "cbwire-upload:", arguments.value ) ) {
					var uploadFullReference = duplicate( arguments.value );
					var uuid = replaceNoCase( arguments.value, "cbwire-upload:", "", "once" );
					arguments.value = getWireBox().getInstance( name="FileUpload@cbwire", initArguments={ comp=this, params=[ key, [ uuid  ] ] } );		
				}

				comp.setProperty( arguments.key, isNull( arguments.value ) ? "" : arguments.value );	

				if ( structKeyExists( comp.getParent(), "onHydrate#arguments.key#" ) ) {
					invoke( comp.getParent(), "onHydrate#arguments.key#", {
						value : arguments.value,
						data : comp.getDataProperties(),
						computed : comp.getComputedProperties()
					} );
				}
			} );

		}

		if ( structKeyExists( comp.getParent(), "onHydrate" ) ) {
			comp.getParent().onHydrate(
				data=comp.getDataProperties(),
				computed=comp.getComputedProperties()
			);
		}

		// Check if our request contains updates, and if so apply them.
		getCBWIREService().handleConcern( concern="ApplyUpdates", comp=comp );
    }
}