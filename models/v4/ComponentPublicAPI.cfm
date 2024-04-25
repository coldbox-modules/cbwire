<cfscript>
    /**
     * Renders the component's HTML output.
     * This method should be overridden by subclasses to implement specific rendering logic.
     * If not overridden, this method will simply render the view.
     */
    function renderIt() {
        return view( _getViewPath() );
    }

    /**
     * Renders a specified view by converting dot notation to path notation and appending .cfm if necessary.
     * Then, it returns the HTML content.
     *
     * @param viewPath The dot notation path to the view template to be rendered, without the .cfm extension.
     * @param params A struct containing the parameters to be passed to the view template.
     * @return The rendered HTML content as a string.
     */
    function view( viewPath, params = {} ) {
        // Normalize the view path
        var normalizedPath = _getNormalizedViewPath( viewPath );
        // Render the view content and trim the result
        var trimmedHTML = trim( _renderViewContent( normalizedPath, arguments.params ) );
        // Validate the HTML content to ensure it has a single outer element
        _validateSingleOuterElement( trimmedHTML);
        // If this is the initial load, encode the snapshot and insert Livewire attributes
        if ( variables._initialLoad ) {
            // Encode the snapshot for HTML attribute inclusion and process the view content
            var snapshotEncoded = _encodeAttribute( serializeJson( _getSnapshot() ) );
            return _insertInitialLivewireAttributes( trimmedHTML, snapshotEncoded, variables._id );
        } else {
            // Return the trimmed HTML content
            return _insertSubsequentLivewireAttributes( trimmedHTML );
        }
    }

	/**
	 * Get a instance object from WireBox
	 *
	 * @name The mapping name or CFC path or DSL to retrieve
	 * @initArguments The constructor structure of arguments to passthrough when initializing the instance
	 * @dsl The DSL string to use to retrieve an instance
	 *
	 * @return The requested instance
	 */
	function getInstance( name, initArguments = {}, dsl ){
        return variables._wirebox.getInstance( argumentCollection=arguments );
    }

    /**
     * Captures a dispatch to be executed later
     * by the browser.
     * 
     * @event string | The event to dispatch.
     * @args* | The parameters to pass to the listeners.
     *
     * @return void
     */
    function dispatch( event ) {
       // Convert params to an array first
       var paramsAsArray = _parseDispatchParams( argumentCollection=arguments );
       // Append the dispatch to our dispatches array
       variables._dispatches.append( { "name": arguments.event, "params": paramsAsArray } );
    }

    /**
     * Dispatches an event to the current component.
     *
     * @event string | The event to dispatch.
     * @return void 
     */
    function dispatchSelf( event ) {
       // Convert params to an array first
       var paramsAsArray = _parseDispatchParams( argumentCollection=arguments );
       // Append the dispatch to our dispatches array
       variables._dispatches.append( { "name": arguments.event, "params": paramsAsArray, "self": true } );

    }

    /**
     * Dispatches a event to another component
     * 
     * @name string | The component to dispatch to.
     * @event string | The method to dispatch.
     * 
     * @return void
     */
    function dispatchTo( name, event ) {
        // Convert params to an array first
        var paramsAsArray = _parseDispatchParams( argumentCollection=arguments );
        // Append the dispatch to our dispatches array
        variables._dispatches.append( { "name": arguments.event, "params": paramsAsArray, "component": arguments.component } );
    }

    /**
     * Instantiates a CBWIRE component, mounts it,
     * and then calls its internal renderIt() method.
     *
     * This is nearly identical to the wire method defined 
     * in the CBWIREController component, but it is intended
     * to provide the wire() method when including nested components
     * and provides tracking of the child.
     *
     * @param name The name of the component to load.
     * @param params The parameters you want mounted initially. Defaults to an empty struct.
     * @param key An optional key parameter. Defaults to an empty string.
     *
     * @return An instance of the specified component after rendering.
     */
    function wire(required string name, struct params = {}, string key = "") {
        // Generate a key if one is not provided
        if ( !arguments.key.len() ) {
            arguments.key = _generateWireKey();
        }

        /*
            If the parent is loaded from a subsequent request,
            check if the child has already been rendered.
        */
        if ( !variables._initialLoad ) {
            var incomingPayload = get_IncomingPayload();
            var children = incomingPayload.snapshot.memo.children;
            // Are we trying to render a child that has already been rendered?
            if ( children.keyExists( arguments.key ) ) {
                var componentTag = children[ arguments.key ][1]; 
                var componentId = children[ arguments.key ][2];
                // Re-track the rendered child
                variables._children.append( {
                    "#arguments.key#": [
                        componentTag,
                        componentId
                    ]
                } );
                // We've already rendered this child, so return a stub for it
                return "<#componentTag# wire:id=""#componentId#""></#componentTag#>";
            }
        }
        // Instaniate this child component as a new component
        var instance = variables._CBWIREController.createInstance(argumentCollection=arguments)
                ._withParent( this )
                ._withEvent( variables._event )
                ._withParams( arguments.params )
                ._withKey( arguments.key );
        // Render it out
        var rendering = instance.renderIt();
        // Based on the rendering, determine our outer component tag
        var componentTag = _getComponentTag( rendering );
        // Track the rendered child
        variables._children.append( {
            "#arguments.key#": [
                componentTag,
                instance._getId()
            ]
        } );

        return instance.renderIt();
    }

    /**
     * Provides the teleport() method to be used in views.
     * 
     * @selector string | The selector to teleport to.
     * 
     * @return string
     */
    function teleport( selector ){
        return "<template x-teleport=""#arguments.selector#"">";
    }

    /**
     * Provides the endTeleport() method to be used in views.
     * 
     * @return string
     */
    function endTeleport(){
        return "</template>";
    }

    /**
     * Provides cbvalidation method to be used in actions and views.
     * 
     * @return ValidationResult
     */
    function validate( target, fields, constraints, locale, excludeFields, includeFields, profiles ){
		arguments.target = isNull( arguments.target ) ? _getDataProperties() : arguments.target;
		arguments.constraints = isNull( arguments.constraints ) ? _getConstraints() : arguments.constraints;
		variables._validationResult = _getValidationManager().validate( argumentCollection = arguments );
		return variables._validationResult;
    }

    /**
     * Provides cbvalidation method to be used in actions and views,
     * throwing an exception if validation fails.
     * 
     * @return ValidationResult
     * 
     * @throws ValidationException
     */
    function validateOrFail( target, fields, constraints, locale, excludeFields, includeFields, profiles ){
		arguments.target = isNull( arguments.target ) ? _getDataProperties() : arguments.target;
		arguments.constraints = isNull( arguments.constraints ) ? _getConstraints() : arguments.constraints;
        _getValidationManager().validateOrFail( argumentCollection = arguments )
		variables._validationResult = _getValidationManager().validate( argumentCollection = arguments );
		return variables._validationResult;
    }

    /**
     * Returns true if the validation result has errors.
     * 
     * @return boolean
     */
    function hasErrors( field ){
        return variables._validationResult.hasErrors( arguments.field );
    }

    /**
     * Resets a data property to it's initial value.
     * Can be used to reset all data properties, a single data property, or an array of data properties.
     * 
     * @return 
     */
    function reset( property ){
		if ( isNull( arguments.property ) ) {
			// Reset all properties
			variables.data.each( function( key, value ){
				reset( key );
			} );
		} else if ( isArray( arguments.property ) ) {
			// Reset each property in our array individually
			arguments.property.each( function( prop ){
				reset( prop );
			} );
		} else {
			var initialState = variables._initialDataProperties;
			// Reset individual property
            variables.data[ arguments.property ] = initialState[ arguments.property ];
		}
	}

    /**
     * Resets all data properties except the ones specified.
     * 
     * @return void
     */
    function resetExcept( property ){
        if ( isNull( arguments.property ) ) {
			throw( type="ResetException", message="Cannot reset a null property." );
		}

		// Reset all properties except what was provided
		_getDataProperties().each( function( key, value ){
			if ( isArray( property ) ) {
				if ( !arrayFindNoCase( property, arguments.key ) ) {
					reset( key );
				}
			} else if ( property != key ) {
				reset( key );
			}
		} );
    }
</cfscript>