<!---
These methods represent public methods that we expect users to call or use
within their own components.

These are separated out from the internal private methods ( $methodName() ) which
are denoted by a dollar sign.
--->
<cfscript>
    /**
	 * Returns LogBox instance.
	 *
	 * @return LogBox
	 */
	function getLogBox(){
		return variables.logbox;
	}

	/**
	 * Returns Logger instance.
	 */
	function getLogger(){
		return variables.log;
	}

    /**
	 * Invokes a postRefresh event and currently nothing else.
	 * This is used with cbwire's polling functionality which
	 * refreshes the component.
	 *
	 * @return Void
	 */
	function refresh(){
		// Invoke 'postRefresh' event
		$invokeMethod( "postRefresh" );
	}

    /**
	 * Emits a global event from our cbwire component.
	 *
	 * @eventName String | The name of our event to emit.
	 * @parameters Struct | The params passed with the emitter.
	 * @trackEmit Boolean | True if you want to notify the UI that the emit occurred.
	 */
	function emit(
		required eventName,
		parameters = {},
		trackEmit  = true
	){
		// Invoke 'preEmit' event
		$invokeMethod(
			methodName = "preEmit",
			eventName  = arguments.eventName,
			parameters = arguments.parameters
		);

		// Invoke 'preEmit[EventName]' event
		$invokeMethod(
			methodName = "preEmit" & arguments.eventName,
			parameters = arguments.parameters
		);

		// Capture the emit as we will need to notify the UI in our response
		if ( arguments.trackEmit ) {
			var emitter = createObject(
				"component",
				"cbwire.models.emit.BaseEmit"
			).init(
				arguments.eventName,
				arguments.parameters
			);

			variables.$trackEmit( emitter );
		}

		var listeners = $getListeners();

		if ( structKeyExists( listeners, eventName ) ) {
			var listener = listeners[ eventName ];

			if ( len( arguments.eventName ) && $hasMethod( listener ) ) {
				return $invokeMethod( listener );
			}
		}

		// Invoke 'postEmit' event
		$invokeMethod(
			methodName = "postEmit",
			eventName  = arguments.eventName,
			parameters = arguments.parameters
		);

		// Invoke 'postEmit[EventName]' event
		$invokeMethod(
			methodName = "postEmit" & arguments.eventName,
			parameters = arguments.parameters
		);
	}

	/**
	 * Emits an event that is scoped to just the current cbwire component.
	 *
	 * Additional parameters can be passed through.

	 * @eventName String | The name of our event to emit.
	 * @parameters Struct | The emitter's params.
	 *
	 * @return Void
	 */
	function emitSelf( required eventName, parameters = {} ){
		var emitter = createObject(
			"component",
			"cbwire.models.emit.EmitSelf"
		).init(
			arguments.eventName,
			arguments.parameters
		);

		// Capture the emit as we will need to notify the UI in our response
		variables.$trackEmit( emitter );
	}

	/**
	 * Emits an event that is scoped to parents and not children or sibling components.
	 *
	 * Additional parameters can be passed through.
	 * @eventName String | The name of our event to emit.
	 * @parameters Struct  The emitter's params.
	 *
	 * @return Void
	 */
	function emitUp( required eventName, parameters = {} ){
		var emitter = createObject(
			"component",
			"cbwire.models.emit.EmitUp"
		).init(
			arguments.eventName,
			arguments.parameters
		);

		// Capture the emit as we will need to notify the UI in our response
		variables.$trackEmit( emitter );
	}

	/**
	 * Emits an event that is scoped to only a specific compnoent.
	 *
	 * Additional parameters can be passed through.
	 * @eventName String | The name of our event to emit.
	 * @componentName String | The name of our component to emit to.
	 * @parameters Array | The emitter's params. Must be an array to preserve order of arguments that are return to cbwire.
	 *
	 * @return Void
	 */
	function emitTo(
		required eventName,
		required componentName,
		parameters = []
	){
		var emitter = createObject(
			"component",
			"cbwire.models.emit.EmitTo"
		).init(
			arguments.eventName,
			arguments.componentName,
			arguments.parameters
		);

		// Capture the emit as we will need to notify the UI in our response
		variables.$trackEmit( emitter );
	}

    /**
	 * Renders our component's view and returns the rendering.
	 *
	 * @return String
	 */
	function renderView(){
		// Pass the properties of the cbwire component as variables to the view
		arguments.args = $getState( includeComputed = true );

		// Render our view using coldbox rendering
		var rendering = variables.$renderer.renderView( argumentCollection = arguments );

		// Add properties to top element to make cbwire actually work.
		return variables.$applyWiringToOuterElement( rendering );
	}

    /**
	 * Declares that cbwire should not render the component's template.
	 * This is typically used for performance reasons.
	 * @return Void
	 */
	function noRender(){
		variables.$noRender = true;
	}

    /**
	 * Resets a property back to it's original state when the component
	 * was initially hydrated.
	 *
	 * This accepts either a single property or an array of properties
	 *
	 * @return Void
	 */
	function reset( property ){
		if ( isArray( arguments.property ) ) {
			// Reset each property in our array individually
			arguments.property.each( function( prop ){
				reset( prop );
			} );
		} else {
			// Reset individual property
			$set(
				arguments.property,
				variables.getMountedState()[ arguments.property ]
			);
		}
	}
</cfscript>