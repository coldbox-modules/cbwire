component accessors="true" singleton {

	property name="wirebox" inject="wirebox";
	property name="requestService" inject="coldbox:requestService";
	property name="dataUtility" inject="DataUtility@cbwire";

	function handle( comp ){
		if ( !hasUpdates() ) {
			return;
		}

		var beforeSyncInputState = duplicate( comp.getDataProperties() );

		var hasDataPropertyUpdates = getUpdates().reduce( function( agg, update ) {
			if ( update.isUpdatingDataProperty() ) {
				agg = true;
			}
			return agg;
		}, false );
		/*
			Run the Sync Input's first and track
			what fields are being synced. We do this
			so later we can determine if any data properties
			changed after calling actions.
		*/
		getUpdates()
			.filter( function( update ){
				return update.isUpdatingDataProperty();
			} )
			.each( function( update ){
				// Apply the update
				arguments.update.apply( comp );
			} );

		var afterSyncInputState = duplicate( comp.getDataProperties() );

		getUpdates()
			.filter( function( update ){
				return update.isUpdatingDataProperty()
			} )
			.each( function( update ){
				var oldValue = dataUtility.getValueByPath( beforeSyncInputState, update.getName() );
				var newValue = dataUtility.getValueByPath( afterSyncInputState, update.getName() );

				comp.invokeMethod(
					methodName = "onUpdate" & update.getName(),
					passThroughParameters = {
						"newValue" : newValue,
						"oldValue" : oldValue
					}
				);
			} );

		// Update the state of our component with each of our updates
		getUpdates()
			.filter( function( update ){
				return !isInstanceOf( update, "SyncInput" );
			} )
			.each( function( update ){
				arguments.update.apply( comp );
			} );

		// Fire our postUpdate lifecycle event.
		if ( hasDataPropertyUpdates ) {
		comp.invokeMethod(
			methodName = "onUpdate",
			passThroughParameters = {
				"newValues" : afterSyncInputState,
				"oldValues" : beforeSyncInputState
			}
		);
		}

		// Determine "dirty" properties
		var dirtyProperties = afterSyncInputState.reduce( function( agg, key, value ){
			var oldValue = comp.getDataProperties()[ arguments.key ];

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

		dirtyProperties.each( function( dirtyProperty ){
			comp._addDirtyProperty( dirtyProperty );
		} );
	}

	/**
	 * Returns true if our request context contains an 'updates' property.
	 *
	 * @return Boolean
	 */
	function hasUpdates(){
		return structKeyExists( getCollection(), "updates" ) && isArray( getCollection().updates ) && arrayLen(
			getCollection().updates
		);
	}

	/**
	 * Returns the current ColdBox RequestContext event.
	 *
	 * @return RequestContext
	 */
	function getEvent(){
		return getRequestService().getContext();
	}

	/**
	 * Returns our event's public request collection.
	 *
	 * @return Struct
	 */
	function getCollection(){
		return getEvent().getCollection( argumentCollection = arguments );
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

}
