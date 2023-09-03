component extends="BaseRenderer" {

	/**
	 * A beautiful start.
	 */
	function start( parent, parentCFCPath ) {
        setIsInitialRendering( false );
        return super.start( argumentCollection=arguments );
    }

	/**
	 * Hydrates the incoming component with state from our request.
	 *
	 * @wireRequest CBWireRequest
	 *
	 * @return Component
	 */
	function hydrate(){
		var cbwireRequest = getInstance( "CBWireRequest@cbwire" );

        if ( hasFingerprint() ) {
			setID( getFingerPrint()[ "id" ] );
		}

		setBeforeHydrationState( duplicate( getState() ) );

		if ( hasServerMemoData() ) {
			getDataProperties().each( function( key, value ) {
				if ( structKeyExists( getServerMemoData(), key ) ) {
					getDataProperties()[ key ] = getServerMemoData()[ key ];
				}
			} );
		}

		// Check if our request contains a server memo, and if so update our component state.
		if ( hasServerMemo() ) {
			var serverMemo = getServerMemo();

			serverMemo.data.each( function( key, value ){
				if ( !isNull( arguments.value ) && isSimpleValue( arguments.value ) && findNoCase( "cbwire-upload:", arguments.value ) ) {
					var uploadFullReference = duplicate( arguments.value );
					var uuid = replaceNoCase( arguments.value, "cbwire-upload:", "", "once" );
					arguments.value = getController().getWireBox().getInstance( name="FileUpload@cbwire", initArguments={ comp=this, params=[ key, [ uuid  ] ] } );
				}
				invokeMethod(
					methodName = "set" & arguments.key,
					value      = isNull( arguments.value ) ? "" : arguments.value
				);					

				if ( structKeyExists( getParent(), "onHydrate#arguments.key#" ) ) {
					invoke( getParent(), "onHydrate#arguments.key#", {
						data : getDataProperties(),
						computed : getComputedProperties()
					} );
				}
			} );

			if ( hasChildren() ) {
				variables.$children = getChildren();
			}
		}

		if ( structKeyExists( getParent(), "onHydrate" ) ) {
			getParent().onHydrate(
				data=getDataProperties(),
				computed=getComputedProperties()
			);
		}

		// Check if our request contains updates, and if so apply them.
		if ( hasUpdates() ) {
			applyUpdates();
		}

		return this;
	}

	/**
	 * Returns an array of WireUpdate objects with our updates from the request context.
	 *
	 * @return Array | WireUpdate
	 */
	function getUpdates(){
		return getCollection()[ "updates" ].map( function( update ){
			var casedType = arguments.update.type;

			casedType = reReplaceNoCase( casedType, "^(.)", "\U\1", "one" );

			return getWirebox().getInstance(
				name = "#casedType#@cbwire",
				initArguments = { "update" : arguments.update }
			);
		} );
	}

	/**
	 * Applies any updates in our request to the specified cbwire component
	 *
	 * @return Void
	 */
	function applyUpdates(){
		// Fire our preUpdate lifecycle event.
		invokeMethod( "preUpdate" );
		var beforeSyncInputState = duplicate( getDataProperties() );

		/*
			Run the Sync Input's first and track 
			what fields are being synced. We do this
			so later we can determine if any data properties
			changed after calling actions.
		*/
		getUpdates().filter( function( update ) {
			return update.isUpdatingDataProperty();
		} ).each( function( update ) {
			// Apply the update
			arguments.update.apply( this );
		} );

		var afterSyncInputState = duplicate( getDataProperties() );

		getUpdates().filter( function(update ) {
			return update.isUpdatingDataProperty()			
		} ).each( function( update ) {
			var oldValue = beforeSyncInputState[ update.getName() ];
			var newValue = afterSyncInputState[ update.getName() ];

			invokeMethod(
				methodName = "onUpdate" & update.getName(),
				passThroughParameters = { "newValue": newValue, "oldValue": oldValue }
			);
		} );

		// Update the state of our component with each of our updates
		getUpdates().filter( function( update ) {
			return !isInstanceOf( update, "SyncInput" );
		} ).each( function( update ) {
			arguments.update.apply( this );
		} );

		// Fire our postUpdate lifecycle event.
		invokeMethod( 
			methodName = "onUpdate",
			passThroughParameters = {
				"newValues": afterSyncInputState,
				"oldValues": beforeSyncInputState
			}
		);


		// Determine "dirty" properties
		var dirtyProperties = afterSyncInputState.reduce( function( agg, key, value ) {
			var oldValue = getDataProperties()[ arguments.key ];
			
			if ( isObject( arguments.value ) ) {
				return agg;
			} else if ( isSimpleValue( oldValue ) && oldValue != arguments.value ) {
				agg.append( arguments.key );
			} else if ( 
				( isArray( oldValue ) && isArray( arguments.value ) ) ||
				( isStruct( oldValue ) ) && isStruct( arguments.value )
			) {
				if ( serializeJSON( oldValue ) != serializeJSON( arguments.value ) ) {
					agg.append( arguments.key );
				}
			}
			return agg;
		}, [] );
		

		dirtyProperties.each( function( dirtyProperty ) {
			_addDirtyProperty( dirtyProperty );
		});
	}

	/**
	 * Returns true if our request context contains a 'fingerprint' property.
	 *
	 * @return Boolean
	 */
	function hasFingerprint(){
		return structKeyExists( getCollection(), "fingerprint" );
	}


	/**
	 * Returns the serverMemo from our request context.
	 *
	 * @return struct
	 */
	function getServerMemo(){
		return getCollection().serverMemo;
	}

	/**
	 * Returns true if the server memo contains children
	 */
	function hasChildren(){
		return hasServerMemo() && isStruct( getChildren() ) && len(
			structKeyList( getCollection().serverMemo.children )
		);
	}

	/**
	 * Returns children in server memo
	 */
	function getChildren(){
		return getCollection().serverMemo.children;
	}

	/**
	 * Returns the fingerprint for the request.
	 *
	 * @return Struct
	 */
	function getFingerprint(){
		return getCollection().fingerprint;
	}

	/**
	 * Returns true if our request context contains an 'updates' property.
	 *
	 * @return Boolean
	 */
	function hasUpdates(){
		return structKeyExists( getCollection(), "updates" ) && isArray( getCollection().updates ) && arrayLen( getCollection().updates );
	}

	/**
	 * Returns true if our server memo contains a data property.
	 *
	 * @return Boolean
	 */
	function hasServerMemoData(){
		return hasServerMemo() && structKeyExists( getServerMemo(), "data" );
	}

	/**
	 * Returns true if our request context contains a 'serverMemo' property.
	 *
	 * @return Boolean
	 */
	function hasServerMemo(){
		return structKeyExists( getCollection(), "serverMemo" );
	}

	/**
	 * Returns our data
	 *
	 * @return Struct
	 */
	function getServerMemoData(){
		return getServerMemo().data;
	}

}