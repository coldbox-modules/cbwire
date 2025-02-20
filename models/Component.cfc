component output="true" {

    property name="_globalSettings" inject="coldbox:modulesettings:cbwire";

    property name="_CBWIREController" inject="CBWIREController@cbwire";

    property name="_wirebox" inject="wirebox";

    property name="_id";
    property name="_compileTimeKey";
    property name="_parent";
    property name="_initialLoad";
    property name="_lazyLoad";
    property name="_lazyIsolated";
    property name="_initialDataProperties";
    property name="_incomingPayload";
    property name="_dataPropertyNames";
    property name="_validationResult";
    property name="_params";
    property name="_key";
    property name="_event";
    property name="_children";
    property name="_metaData";
    property name="_dispatches";
    property name="_cache"; // internal cache for storing data
    property name="_xjs";
    property name="_returnValues";
    property name="_redirect";
    property name="_redirectUsingNavigate";
    property name="_isolate";
    property name="_path";
    property name="_renderedContent";
    property name="_scripts";
    property name="_assets";

    /**
     * Constructor
     *
     * @return The initialized component instance.
     */
    function init() {
        return this;
    }

    /**
     * Initializes the component after dependency injection, setting a unique ID if not already set.
     * This method should be called by any extending component's init method if overridden.
     * Extending components should invoke super.init() to ensure the base initialization is performed.
     *
     * @return The initialized component instance.
     */
    function onDIComplete() {
        if ( isNull( variables._id ) ) {
            variables._id = lCase( hash( createUUID() ) );
        }

        variables._params = [:];
        variables._compileTimeKey = hash( getCurrentTemplatePath() );
        variables._key = "";
        variables._cache = [:];
        variables._dispatches = [];
        variables._children = [:];
        variables._initialLoad = true;
        variables._lazyLoad = false;
        variables._lazyIsolated = true;
        variables._xjs = [];
        variables._returnValues = [];
        variables._redirect = "";
        variables._redirectUsingNavigate = false;
        variables._isolate = false;
        variables._renderedContent = "";
        variables._scripts = [:];
        variables._assets = [:];

        /*
            Cache the component's meta data on initialization
            for fast access where needed.
        */
        variables._metaData = getMetaData( this );

        /*
            Prep our data properties
        */
        _prepareDataProperties();

        /*
            Prep our computed properties for caching
        */
        _prepareComputedProperties();

        /*
            Prep generated getters and setters for data properties
        */
        _prepareGeneratedGettersAndSetters();

        /*
            Prep isolation
        */
        _prepareIsolation();

        /*
            Prep for lazy loading
        */
        _prepareLazyLoading();

        /*
            Prep listeners
        */
        _prepareListeners();

        /*
            Fire onBoot lifecycle method
            if it exists
        */
        if ( structKeyExists( this, "onBoot" ) ) {
            invoke( this, "onBoot" );
        }

        return this;
    }

    /*
        ==================================================================
        Public API
        ==================================================================
    */

    /**
     * Fires when the component is mounted.
     * Override this method in your component to handle onMount logic.
     */
    function onMount() {}

    /**
     * Returns the CBWIRE Controller
     *
     * @return CBWIREController
     */
    function getCBWIREController(){
        return variables._CBWIREController;
    }

    /**
     * renderIt left for backwards compatibility.
     *
     * @return string
     */
    function renderIt() {
        return "";
    }

    /**
     * Renders the component's HTML output.
     * This method should be overridden by subclasses to implement specific rendering logic.
     * If not overridden, this method will simply render the view.
     */
    function onRender() {
        local.renderIt = renderIt();
        if ( local.renderIt.len() ) {
            return local.renderIt;
        }
        return template( _getViewPath() );
    }

    /**
     * Pass-through method for ColdBox's view() method.
     *
     * @view                   The the view to render, if not passed, then we look in the request context for the current set view.
     * @args                   A struct of arguments to pass into the view for rendering, will be available as 'args' in the view.
     * @module                 The module to render the view from explicitly
     * @cache                  Cached the view output or not, defaults to false
     * @cacheTimeout           The time in minutes to cache the view
     * @cacheLastAccessTimeout The time in minutes the view will be removed from cache if idle or requested
     * @cacheSuffix            The suffix to add into the cache entry for this view rendering
     * @cacheProvider          The provider to cache this view in, defaults to 'template'
     * @collection             A collection to use by this Renderer to render the view as many times as the items in the collection (Array or Query)
     * @collectionAs           The name of the collection variable in the partial rendering.  If not passed, we will use the name of the view by convention
     * @collectionStartRow     The start row to limit the collection rendering with
     * @collectionMaxRows      The max rows to iterate over the collection rendering with
     * @collectionDelim        A string to delimit the collection renderings by
     * @prePostExempt          If true, pre/post view interceptors will not be fired. By default they do fire
     * @name                   The name of the rendering region to render out, Usually all arguments are coming from the stored region but you override them using this function's arguments.
     *
     * @return The rendered view
     */
    function view(
        view                   = "",
        struct args            = {},
        module                 = "",
        boolean cache          = false,
        cacheTimeout           = "",
        cacheLastAccessTimeout = "",
        cacheSuffix            = "",
        cacheProvider          = "template",
        collection,
        collectionAs               = "",
        numeric collectionStartRow = "1",
        numeric collectionMaxRows  = 0,
        collectionDelim            = "",
        boolean prePostExempt      = false,
        name
    ) {
        return variables._CBWIREController.view( argumentCollection=arguments );
    }

    /**
     * Renders a specified template by converting dot notation to path notation and appending .cfm if necessary.
     * Then, it returns the HTML content.
     *
     * @viewPath string | The dot notation path to the template to be rendered, without the .cfm extension.
     * @params struct | A struct containing the parameters to be passed to the view template.
     *
     * @return The rendered HTML content as a string.
     */
    function template( viewPath, params = {} ) {
        // Normalize the view path
        local.normalizedPath = _getNormalizedViewPath( arguments.viewPath );
        // Render the view content and trim the result
        return _renderViewContent( local.normalizedPath, arguments.params );
    }

    /**
     * Get a instance object from WireBox
     *
     * @name string | The mapping name or CFC path or DSL to retrieve
     * @initArguments struct | The constructor structure of arguments to passthrough when initializing the instance
     * @dsl string | The DSL string to use to retrieve an instance
     *
     * @return The requested instance
     */
    function getInstance( name, initArguments = {}, dsl ) {
        return variables._wirebox.getInstance( argumentCollection=arguments );
    }

    /**
     * Redirects a user to a specified URL or URI.
     *
     * @redirectURL string | The URL or URI to redirect the user to.
     * @redirectUsingNavigate boolean | Whether to use the navigate method to redirect.
     */
    function redirect( redirectURL, redirectUsingNavigate = false ) {
        variables._redirect = arguments.redirectURL;
        variables._redirectUsingNavigate = arguments.redirectUsingNavigate;
    }

    /**
     * Captures a dispatch to be executed later
     * by the browser.
     *
     * @event string | The event to dispatch.
     * @params | The parameters to pass to the listeners.
     *
     * @return void
     */
    function dispatch( event, params = [:] ) {
       // Convert params to an array first
       local.params = _parseDispatchParams( arguments.params );
       // Append the dispatch to our dispatches array
       variables._dispatches.append( [ "name": arguments.event, "params": local.params ] );
    }

    /**
     * Dispatches an event to the current component.
     *
     * @event string | The event to dispatch.
     * @params struct | The parameters to pass to the method.
     *
     * @return void
     */
    function dispatchSelf( event, params = [:] ) {
       local.params = _parseDispatchParams( arguments.params );
       // Append the dispatch to our dispatches array
       variables._dispatches.append( [ "name": arguments.event, "params": local.params, "self": true ] );
    }

    /**
     * Dispatches a event to another component
     *
     * @to string | The component to dispatch to.
     * @event string | The method to dispatch.
     * @params struct | The parameters to pass to the method.
     *
     * @return void
     */
    function dispatchTo( to, event, params = [:]) {
        local.params = _parseDispatchParams( arguments.params );
        // Append the dispatch to our dispatches array
        variables._dispatches.append( [ "name": arguments.event, "params": local.params, "to": arguments.to ] );
    }

    /**
     * Instantiates a CBWIRE component, mounts it,
     * and then calls its internal onRender() method.
     *
     * This is nearly identical to the wire method defined
     * in the CBWIREController component, but it is intended
     * to provide the wire() method when including nested components
     * and provides tracking of the child.
     *
     * @name string | The name of the component to load.
     * @params struct | The parameters you want mounted initially. Defaults to an empty struct.
     * @key string | An optional key parameter. Defaults to an empty string.
     * @lazy boolean | Optional parameter to lazy load the component. Defaults to false.
     * @lazyIsolated boolean | Optional parameter to lazy load the component in an isolated scope. Defaults to true.
     *
     * @return An instance of the specified component after rendering.
     */
    function wire(required string name, struct params = {}, string key = "", lazy = false, lazyIsolated = true ) {
        // Generate a key if one is not provided
        if ( !arguments.key.len() ) {
            arguments.key = _generateWireKey();
        }

        /*
            If the parent is loaded from a subsequent request,
            check if the child has already been rendered.
        */
        if ( !variables._initialLoad ) {
            local.incomingPayload = variables._incomingPayload;
            local.children = local.incomingPayload.snapshot.memo.children;
            // Are we trying to render a child that has already been rendered?
            if ( isStruct( local.children ) && local.children.keyExists( arguments.key ) ) {

                local.componentTag = local.children[ arguments.key ][1];
                local.componentId = local.children[ arguments.key ][2];
                // Re-track the rendered child
                variables._children.append( {
                    "#arguments.key#": [
                        local.componentTag,
                        local.componentId
                    ]
                } );
                // We've already rendered this child, so return a stub for it
                return "<#local.componentTag# wire:id=""#local.componentId#""></#local.componentTag#>";
            }
        }
        // Instaniate this child component as a new component
        local.instance = variables._CBWIREController.createInstance(argumentCollection=arguments)
            ._withPath( arguments.name )
            ._withParent( this )
            ._withEvent( variables._event )
            ._withParams( arguments.params, arguments.lazy )
            ._withKey( arguments.key )
            ._withLazy( arguments.lazy );

        // Check if lazy loading is enabled
        if ( arguments.lazy ) {
            local.lazyRendering = local.instance._generateXIntersectLazyLoadSnapshot( params=arguments.params );
            // Based on the rendering, determine our outer component tag
            local.componentTag = _getComponentTag( local.lazyRendering );
            // Track the rendered child
            variables._children.append( [
                "#arguments.key#": [
                    local.componentTag,
                    local.instance._getId()
                ]
            ] );

            return local.lazyRendering;
        } else {
            // Render it out normally
            local.rendering = local.instance._render();
            // Based on the rendering, determine our outer component tag
            local.componentTag = _getComponentTag( local.rendering );
            // Track the rendered child
            variables._children.append( {
                "#arguments.key#": [
                    local.componentTag,
                    local.instance._getId()
                ]
            } );

            return local.instance._render();
        }
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
     *
     * @throws ValidationException
     */
    function validateOrFail(){
        local.validationResults = validate();
        if ( local.validationResults.hasErrors() ) {
            throw( type="ValidationException", message="Validation failed" );
        }
    }

    /**
     * Returns true if the validation result has errors.
     *
     * @return boolean
     */
    function hasErrors() {
        return variables._validationResult.hasErrors();
    }

    /**
     * Returns true if a specific property has errors.
     *
     * @return boolean
     */
    function hasError( prop ) {
        return variables._validationResult.hasErrors( arguments.prop );
    }

    /**
     * Returns array of ValidationError objects containing all of theerrors.
     *
     * @return array
     */
    function getErrors() {
        return variables._validationResult.getErrors();
    }

    /**
     * Returns the first error message for a given field.
     *
     * @return string
     */
    function getError( prop ) {
        local.allErrors = variables._validationResult.getAllErrors( arguments.prop );
        if ( local.allErrors.len() ) {
            return local.allErrors.first();
        }
        return "";
    }

    /**
     * Returns true if property passes validation.
     *
     * @return boolean
     */
    function validates( prop ) {
        return !hasErrors( arguments.prop );
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

    /**
     * Returns a reference to the LivewireJS entangle method
     * which provides model binding between AlpineJS and CBWIRE.
     *
     * @prop string | The data property you want to bind client and server side.
     *
     * @returns string
     */
    function entangle( required prop ) {
        return "window.Livewire.find( '#variables._id#' ).entangle( '#arguments.prop#' )";
    }

    /**
     * Provide ability to return and execute Javascript
     * in the browser.
     *
     * @return void
     */
    function js( code ) {
        variables._xjs.append( arguments.code );
    }

    /**
     * Streams content to the client.
     *
     * @target string | The target to stream to.
     * @content string | The content to stream.
     * @replace boolean | Whether to replace the content.
     *
     * @return void
     */
    function stream( target, content, replace ) output="true"{
        if ( !variables._event.privateValueExists( "_cbwire_stream" ) ) {
            cfcontent( reset=true );
            variables._event.setPrivateValue( "_cbwire_stream", true );
            cfheader( statusCode=200, statustext="OK" );
            cfheader( name="Cache-Control", value="no-cache, private" );
            cfheader( name="Host", value=cgi.http_host );
            cfheader( name="Content-Type", value="text/event-stream" );
            cfheader( name="Connection", value="close" );
            cfheader( name="X-Accel-Buffering", value="no" );
            cfheader( name="X-Livewire-Stream", value=1 );
        }

        local.streamResponse = [
            "stream": true,
            "body": [
                "name": arguments.target,
                "content": arguments.content,
                "replace": arguments.replace
            ],
            "endStream": true
        ];

        writeOutput( serializeJson( local.streamResponse ) );

        cfflush();
    }

    /**
     * Provides a placeholder that is used when lazy loading components.
     * This method returns an empty string. Override this method in your
     * component to provide a custom placeholder.
     *
     * @return string
     */
    function placeholder() {
        return "";
    }

    /**
     * Built in action that does nothing but causes the template
     * to re-render on subsequent requests.
     *
     * @return void
     */
    function $refresh() {}

    /*
        ==================================================================
        Internal API
        ==================================================================
    */

    /**
     * Returns the id of the component.
     *
     * @return string
     */
    function _getId() {
        return variables._id;
    }

    /**
     * Passes a reference to the parent of a child component.
     *
     * @return Component
     */
    function _withParent( parent ) {
        variables._parent = arguments.parent;
        return this;
    }

    /**
     * Passes the path of the component.
     *
     * @path string | The path of the component.
     *
     * @return Component
     */
    function _withPath( path ) {
        variables._path = arguments.path;
        return this;
    }

    /**
     * Passes the current event into our component.
     *
     * @return Component
     */
    function _withEvent( event ) {
        variables._event = arguments.event;
        return this;
    }

    /**
     * Passes in incoming payload to the component
     *
     * @return Component
     */
    function _withIncomingPayload( payload ) {
        variables._incomingPayload = arguments.payload;
        variables._initialLoad = false;
        return this;
    }

    /**
     * Passes params to the component to be used with onMount.
     *
     * @params struct | The parameters to be passed to the component.
     * @lazy boolean | (Optional) A boolean value indicating whether the component should be lazily loaded. Default is false.
     *
     * @return Component The updated component with the specified parameters.
     */
    function _withParams( params, lazy = false ) {
        variables._params = arguments.params;

        if ( arguments.lazy ) return this; // Skip onMount here for lazy loaded components

        // Loop over our params and set them as data properties
        arguments.params.each( function( key, value ) {
            if ( variables.data.keyExists( key ) ) {
                variables.data[ key ] = value;
            }
        } );

        try {
            // Fire onMount if it exists
            onMount(
                event=variables._event,
                rc=variables._event.getCollection(),
                prc=variables._event.getPrivateCollection(),
                params=arguments.params
            );
        } catch ( any e ) {
            throw( type="CBWIREException", message="Failure when calling onMount(). #e.message#" );
        }

        return this;
    }

    /**
     * Passes a key to the component to be used to identify the component
     * on subsequent requests.
     *
     * @key string | The key to be used to identify the component.
     *
     * @return Component
     */
    function _withKey( key ) {
        variables._key = arguments.key;
        return this;
    }

    /**
     * Passes a lazy load flag to the component.
     *
     * @lazy boolean | A boolean value indicating whether the component should be lazily loaded.
     *
     * @return Component
     */
    function _withLazy( lazy ) {
        variables._lazyLoad = arguments.lazy;
        variables._isolate = true;
        return this;
    }

    /**
     * Hydrate the component
     *
     * @componentPayload struct | A struct containing the payload to hydrate the component with.
     *
     * @return void
     */
    function _hydrate( componentPayload ) {
        // Set our component's id to the incoming memo id
        variables._id = arguments.componentPayload.snapshot.memo.id;
        // Append the incoming data to our component's data
        arguments.componentPayload.snapshot.data.each( function( key, value ) {
            variables.data[ key ] = value;
            if ( structKeyExists( this, "onHydrate#key#") ) {
                invoke( this, "onHydrate#key#", { value: value });
            }
        } );
        // Run onHydrate if it exists
        if ( structKeyExists( this, "onHydrate" ) ) {
            invoke( this, "onHydrate", { incomingPayload: arguments.componentPayload.snapshot.data } );
        }

        if ( arguments.componentPayload.calls.len() && arguments.componentPayload.calls[1].method == "_finishUpload" ) {
            local.files = arguments.componentPayload.calls[ 1 ].params[ 2 ];
            local.dataProp = componentPayload.calls[1].params[1];
            local.files.each( function( uuid ) {
                if ( isArray( variables.data[ dataProp ] ) ) {
                    variables.data[ componentPayload.calls[1].params[1] ].append( "fileupload:" & uuid );
                } else {
                    variables.data[ componentPayload.calls[1].params[1] ] = "fileupload:" & uuid;
                }
            } );
        }

        /*
            Provide file uploads to view
        */
        variables.data.each( function( key, value ) {
            if ( isArray( arguments.value ) && arguments.value.len() && isSimpleValue( arguments.value.first() ) && arguments.value[ 1 ] contains "fileupload:" ) {
                // This property is holding an array of file uploads.
                value.each( function( uuid, index ) {
                    local.fileUpload = getInstance( dsl="FileUpload@cbwire" ).load(
                        wire = this,
                        dataPropertyName = key,
                        uuid = uuid.replaceNoCase( "fileupload:", "" )
                    );
                    variables.data[ key ][ index ] = local.fileUpload;
                } );
            } else if ( isSimpleValue( arguments.value ) && arguments.value contains "fileupload:" ) {
                // This property is holding a single file upload.
                variables.data[ arguments.key ] = getInstance( dsl="FileUpload@cbwire" ).load(
                    wire = this,
                    dataPropertyName = key,
                    uuid = arguments.value.replaceNoCase( "fileupload:", "" )
                );
            }
        } );

    }

    /**
     * Apply updates to the component
     *
     * @updates struct | A struct containing the updates to apply to the component.
     *
     * @return void
     */
    function _applyUpdates( updates ) {
        if ( !updates.count() ) return;
        // Capture old values
        local.oldValues = duplicate( data );
        // Array to track which array props were updated
        local.updatedArrayProps = [];
        // Loop over the updates and apply them
        arguments.updates.each( function( key, value ) {
			// validate if key is locked
			_validateLockedProperty( key );

            // Check if we should trim if simple value
            if ( isSimpleValue( arguments.value ) && shouldTrimStringValues() ) {
                arguments.value = trim( arguments.value );
            }

            // Determine if this is an array update
            if ( reFindNoCase( "\.[0-9]+", arguments.key ) ) {
                local.regexMatch = reFindNoCase( "(.+)\.([0-9]+)", arguments.key, 1, true );
                local.propertyName = local.regexMatch.match[ 2 ];
                local.arrayIndex = local.regexMatch.match[ 3 ];
                variables.data[ local.propertyName][ local.arrayIndex + 1 ] = isNumeric( arguments.value ) ? val( arguments.value ) : arguments.value;
                // Track that we updated an array property
                if ( !arrayFindNoCase( updatedArrayProps, local.propertyName ) ) {
                    updatedArrayProps.append( local.propertyName );
                }
            } else {
                local.oldValue = variables.data[ key ];
                variables.data[ key ] = arguments.value;
                if ( structKeyExists( this, "onUpdate#key#") ) {
                    invoke( this, "onUpdate#key#", { value: arguments.value, oldValue: local.oldValue });
                }
            }
        } );

        local.updatedArrayProps.each( function( prop ) {
            variables.data[ arguments.prop ] = variables.data[ arguments.prop ].filter( function( value ) {
                return arguments.value != "__rm__";
            } );
        } );

        // Call onUpdate passing newValues and oldValues
        if ( structKeyExists( this, "onUpdate" ) ) {
            invoke( this, "onUpdate", { newValues: duplicate( variables.data ), oldValues: local.oldValues } );
        }
    }

    /**
     * Validate if key being updated is a locked property.
     *
     * @key string | the data property key being updated.
     *
     * @return void
     */
	function _validateLockedProperty( key ) {
		if( !variables.keyExists("locked") ) return;
		if( isArray( variables.locked ) && arrayFindNoCase( variables.locked, arguments.key ) )
			throw( type="CBWIREException", message="Locked properties cannot be updated." );
		else if ( isSimpleValue( variables.locked ) && listToArray(variables.locked).find( arguments.key ) )
			throw( type="CBWIREException", message="Locked properties cannot be updated." );
	}

    /**
     * Apply calls to the component
     *
     * @calls array | An array of calls to apply to the component.
     *
     * @return void
     */
    function _applyCalls( calls ) {
        arguments.calls.each( function( call ) {
            try {
                local.result = invoke( this, arguments.call.method, arguments.call.params );
                // Capture the return value in case it's needed by the front-end
                variables._returnValues.append( isNull( local.result ) ? javaCast( "null", 0 ) : local.result );
            } catch ( ValidationException e ) {
                // silently fail so the component can continue to render
            } catch( any e ) {
                rethrow;
            }
        } );
    }

    /**
     * Returns the validation manager if it's available.
     * Otherwise throws error.
     *
     * @return ValidationManager
     */
    function _getValidationManager(){
        try {
            return getInstance( dsl="ValidationManager@cbvalidation" );
        } catch ( any e ) {
            throw( type="CBWIREException", message="ValidationManager not found. Make sure the 'cbvalidation' module is installed." );
        }
    }

    /**
     * Returns a struct of cbvalidation constraints.
     *
     * @return struct
     */
    function _getConstraints(){
        if ( variables.keyExists( "constraints" ) ) {
            return variables.constraints;
        }
        return [:];
    }

    /**
     * Parses the dispatch parameters into an array.
     *
     * @params struct | The parameters to parse.
     *
     * @return array
     */
    function _parseDispatchParams( params ) {
        // Leaving here for future expansion
        return arguments.params;
    }

    /**
     * Returns the normalized view path.
     *
     * @viewPath string | The dot notation path to the view template to be rendered, without the .cfm extension.
     *
     * @return string
     */
    function _getNormalizedViewPath( viewPath ) {
        // Replace all dots with slashes to normalize the path
        local.normalizedPath = replace( arguments.viewPath, ".", "/", "all" );

        if ( local.normalizedPath contains "cbwire/models/tmp/" ) {
            return "/" & local.normalizedPath & ".cfm";
        }
        // Check if ".cfm" is present; if not, append it.
        if (not findNoCase(".cfm", local.normalizedPath)) {
            local.normalizedPath &= ".cfm";
        }
        // Ensure the path starts with "/wires/" without duplicating it
        if (!isModulePath() && left(local.normalizedPath, 6) != "wires/") {
            local.normalizedPath = "wires/" & local.normalizedPath;
        }
        // Prepend a leading slash if not present
        if (left(local.normalizedPath, 1) != "/") {
            local.normalizedPath = "/" & local.normalizedPath;
        }

        return local.normalizedPath;
    }

    /**
     * Handles a dispatched event
     *
     * @return void
     */
    function __dispatch( event, params ) {
        local.methodToCall = variables.listeners[ arguments.event ];
        invoke( this, local.methodToCall, arguments.params );
    }

    /**
     * Method that is invoke when a file upload is first requested.
     *
     * @prop string | The property for the file input.
     * @params struct | The parameters to pass to the upload method.
     * @self boolean | Whether to dispatch to self.
     */
    function _startUpload( prop, params, self ) {
        // Generate upload URL
        local.uploadURL = variables._CBWIREController.generateSignedUploadURL( arguments.prop );
        // Dispatch the upload URL
        dispatchSelf(
            event="upload:generatedSignedUrl",
            params=[
                "name"=arguments.prop,
                "url"=local.uploadURL
            ]
        );
    }

    /**
     * Method that is invoked when a file upload is finished.
     *
     * @prop string | The property for the file input.
     * @params struct | The parameters to pass to the upload method.
     * @self boolean | Whether to dispatch to self.
     *
     * @return void
     */
    function _finishUpload( prop, files, self ) {
        // Dispatch the upload URL
        dispatchSelf(
            event="upload:finished",
            params=[
                "name"=arguments.prop,
                "tmpFilenames"=arguments.files
            ]
        );
    }

    /**
     * Fires when missing methods are called.
     * Handles computed properties.
     *
     * @missingMethodName string | The name of the missing method.
     * @missingMethodArguments struct | The arguments passed to the missing method.
     *
     * @return any
     */
    function onMissingMethod( missingMethodName, missingMethodArguments ){
        /*
            Check the component's meta data for functions
            labeled as computed.
        */
        var meta = variables._metaData;
        /*
            Handle generated getters and setters for data properties.
            You see we are also preparing the getters and setters in the init method.
            This is provide access to the dynamic methods both from outside
            the component as well as from within the component.
        */
        if ( arguments.missingMethodName.reFindNoCase( "^get[A-Z].*" ) ) {
            var propertyName = arguments.missingMethodName.reReplaceNoCase( "^get", "" );
            if ( variables.data.keyExists( propertyName ) ) {
                return variables.data[ propertyName ];
            }
        }

        if ( arguments.missingMethodName.reFindNoCase( "^set[A-Z].*" ) ) {
            var propertyName = arguments.missingMethodName.reReplaceNoCase( "^set", "" );
            // Ensure data property exists before setting it
            if ( variables.data.keyExists( propertyName ) ) {
                variables.data[ propertyName ] = arguments.missingMethodArguments[ 1 ];
                return;
            }
        }

        /*
            Throw an exception if the missing method is not a computed property.
        */
        throw( type="CBWIREException", message="The method '#arguments.missingMethodName#' does not exist." );
    }

    /**
     * Generates a checksum for securing the component's data.
     *
     * @return String The generated checksum.
     */
    function _generateChecksum() {
        return "f9f66fa895026e389a10ce006daf3f59afaec8db50cdb60f152af599b32f9192";
        var secretKey = "YourSecretKey"; // This key should be securely retrieved
        return hash(serializeJson(arguments.snapshot) & secretKey, "SHA-256");
    }

    /**
     * Encodes a given string for safe usage within an HTML attribute.
     *
     * @value string | The string to be encoded.
     *
     * @return String The encoded string suitable for HTML attribute inclusion.
     */
    function _encodeAttribute( value ) {
        return arguments.value.replaceNoCase( '"', "&quot;", "all" );
        // return encodeForHTMLAttribute(arguments.value);
    }

    /**
     * Inserts Livewire-specific attributes into the given HTML content, ensuring Livewire can manage the component.
     *
     * @html string | The original HTML content to be processed.
     * @snapshotEncoded string | The encoded snapshot data for Livewire's consumption.
     * @id string | The component's unique identifier.
     *
     * @return String The HTML content with Livewire attributes properly inserted.
     */
    function _insertInitialLivewireAttributes( html, snapshotEncoded, id ) {
        // Trim our html
        arguments.html = arguments.html.trim();
        // Define the wire attributes to append
        local.wireAttributes = 'wire:snapshot="' & arguments.snapshotEncoded & '" wire:effects="#_generateWireEffectsAttribute()#" wire:id="#variables._id#"';
        // Determine our outer element
        local.outerElement = _getOuterElement( arguments.html );
        // Find the position of the opening tag
        local.openingTagStart = findNoCase("<" & local.outerElement, arguments.html);
        local.openingTagEnd = find(">", arguments.html, local.openingTagStart);
        // Insert attributes into the opening tag
        if (local.openingTagStart > 0 && local.openingTagEnd > 0) {
            local.openingTag = mid(arguments.html, local.openingTagStart, local.openingTagEnd - local.openingTagStart + 1);
            local.newOpeningTag = replace(local.openingTag, "<" & local.outerElement, "<" & local.outerElement & " " & local.wireAttributes, "one");
            arguments.html = replace(arguments.html, local.openingTag, local.newOpeningTag, "one");
        }

        return arguments.html;
    }

    /**
     * Inserts subsequent Livewire-specific attributes into the given HTML content.
     *
     * @html string | The original HTML content to be processed.
     *
     * @return String The HTML content with Livewire attributes properly inserted.
     */
    function _insertSubsequentLivewireAttributes( html ) {
        // Trim our html
        arguments.html = arguments.html.trim();
        // Define the wire attributes to append
        local.wireAttributes = "wire:id=""#variables._id#""";
        // Determine our outer element
        local.outerElement = _getOuterElement( arguments.html );
        // Insert attributes into the opening tag
        return arguments.html.reReplaceNoCase( "<" & local.outerElement & "\s*", "<" & local.outerElement & " " & local.wireAttributes & " ", "one" );
    }

    /**
     * Provides on subsequent mounting for lazy loaded components.
     *
     * @snapshot string | The base64 encoded snapshot.
     *
     * @return void
     */
    function _lazyMount( snapshot ) {
        // Decode the base 64 encoded snapshot
        local.decodedSnapshot = deserializeJson( toString( toBinary( arguments.snapshot ) ) );
        // Loop through the forMount array and set the data properties
        local.mountParams = local.decodedSnapshot.data.forMount.reduce( ( acc, item ) => {
            for ( var key in item ) {
                acc[ key ] = item[ key ];
            }
            return acc;
        }, [:] );
        // Call our onMount method with the params
        onMount(
            event=variables._event,
            rc=variables._event.getCollection(),
            prc=variables._event.getPrivateCollection(),
            params=local.mountParams
        );
    }

    /**
     * Renders the content of a view template file.
     * This method is used internally by the view method to render the content of a view template.
     *
     * @normalizedPath string | The normalized path to the view template file.
     * @params struct | The parameters to pass to the view template.
     *
     * @return The rendered content of the view template.
     */
    function _renderViewContent( normalizedPath, params = {} ){
        if ( !variables._renderedContent.len() ) {
            local.templateReturnValues = {};
            // Render our view using an renderer encapsulator
            savecontent variable="local.viewContent" {
                cfmodule(
                    template = "RendererEncapsulator.cfm",
                    cbwireComponent = this,
                    normalizedPath = arguments.normalizedPath,
                    params = arguments.params,
                    returnValues = local.templateReturnValues
                );
            }
            _parseTemplateReturnValues( local.templateReturnValues );
            variables._renderedContent = local.viewContent;
        }

        return variables._renderedContent;
    }

    /**
     * Parses the return values from the RendererEncapsulator.
     *
     * @return void
     */
    function _parseTemplateReturnValues( returnValues ) {
        // Parse and track cbwire:script tags
        arguments.returnValues.filter( function( key, value ) {
            return key.findNoCase( "script" );
        } ).each( function( key, value, result ) {
            // Extract the counter from the tag name
            local.counter = key.replaceNoCase( "script", "" );
            // Create script tag id based on compile time id and counter
            local.scriptTagId = variables._compileTimeKey & "-" & local.counter;
            // Track the script tag
            variables._scripts[ local.scriptTagId ] = value;
        } );

        // Parse and track cbwire:assets tags
        arguments.returnValues.filter( function( key, value ) {
            return key.findNoCase( "assets" );
        } ).each( function( key, value, result ) {
            // Extract the counter from the tag name
            local.counter = key.replaceNoCase( "assets", "" );
            // Create assets tag id based on hash of assets
            local.assetsTagId = hash( value, "MD5" );
            // Track the assets tag
            variables._assets[ local.assetsTagId ] = value;
            local.requestAssets = variables._CBWIREController.getRequestAssets();
            local.requestAssets[ local.assetsTagId ] = value;
        } );
    }

    /**
     * Validates that the HTML content has a single outer element.
     * Ensures the first and last tags match and that the total number of tags is even.
     *
     * @trimmedHtml string | The trimmed HTML content to validate.
     * @throws ApplicationException When the HTML does not meet the single outer element criteria.
     */
    function _validateSingleOuterElement( trimmedHtml ) {
        return; // Skip until we can find a much faster way to validate a single outer element.

        // Define void elements
        local.voidTags = ["area", "base", "br", "col", "command", "embed", "hr", "img", "input", "keygen", "link", "meta", "param", "source", "track", "wbr"];

        // Trim and remove any extra spaces between tags for accurate matching
        local.cleanHtml = trim(arguments.trimmedHtml).replaceAll("\s+>", ">");

        // Regex to find all tags
        local.tags = reMatch("<\/?[a-z]+[^>]*>", local.cleanHtml);

        // Ensure there is at least one tag
        if (arrayLen(local.tags) == 0) {
            throw("ApplicationException", "Template must contain at least one HTML tag.");
        }

        // Check for single outer element by comparing the first and last tag
        local.firstTag = tags.first().replaceAll("<\/?([a-z]+)[^>]*>", "$1");
        local.lastTag = tags.last().replaceAll("<\/?([a-z]+)[^>]*>", "$1");

        // Check if the first and last tags match and are properly nested
        if ( local.firstTag != local.lastTag ) {
            throw("CBWIRETemplateException", "Template does not have matching outer tags.");
        }

        // Additional check to ensure no other top-level tags are present
        local.depth = 0;
        local.tags.each( function( tag, index ) {
            local.tagName = tag.replaceAll("<\/?([a-z]+)[^>]*>", "$1");

            // Skip depth modification for void elements
            if (arrayFindNoCase(voidTags, local.tagName) && left( arguments.tag, 2) != "</") {
                return;
            }

            if (left( arguments.tag, 2) == "</") {
                depth--;
            } else {
                depth++;
            }
            // If depth returns to zero before last tag, or if depth is not zero after last tag, throw exception
            if (depth == 0 && index != tags.len() || index == tags.len() && depth != 0 ) {
                throw("CBWIRETemplateException", "Template has more than one outer element, or is missing an end tag </element>.");
            }
        });
    }

    /**
     * Returns a base64 encoded string of the component's snapshot
     * for lazy loading.
     *
     * @params struct | The parameters to pass to the snapshot.
     *
     * @return string
     */
    function _generateXIntersectLazyLoadSnapshot( params = {} ) {
        local.snapshot = {
            "data": [
                "forMount": [
                    [
                        "s": "arr"
                    ]
                ]
            ],
            "memo": [
                "id": variables._id,
                "name": "__mountParamsContainer",
                "path": "/",
                "method": "GET",
                "children": [],
                "scripts": [],
                "assets": [],
                "errors": [],
                "locale": "en"
            ],
            "checksum": _generateChecksum()
        };

        // Prepend any passed in params into our forMount array
        arguments.params.each( function( key, value ) {
            snapshot.data.forMount.prepend( { "#arguments.key#": arguments.value } );
        } );

        // Serialize the snapshot to JSON and then encode it for HTML attribute inclusion
        local.lazyLoadSnapshot = serializeJson( local.snapshot );

        // Generate the base64 encoded version of the serialized snapshot for use in x-intersect
        local.base64EncodedSnapshot = toBase64( local.lazyLoadSnapshot );

        // Get our placeholder html
        local.html = placeholder();

        // Check if placeholder is even defined, if not throw error
        if ( isNull( local.html ) || !local.html.len() ) {
            throw( type="CBWIREException", message="The placeholder method must be defined for lazy loaded components and it must have the same outer element as your CBWIRE template." );
        }

        // Define the wire attributes to append
        local.wireAttributes = 'wire:snapshot="' & _encodeAttribute( serializeJson( _getSnapshot() ) ) & '" wire:effects="#_generateWireEffectsAttribute()#" wire:id="#variables._id#"' & ' x-intersect="$wire._lazyMount(&##039;' & local.base64EncodedSnapshot & '&##039;)"';

        // Determine our outer element
        local.outerElement = _getOuterElement( local.html );

        // Insert attributes into the opening tag
        return local.html.reReplaceNoCase( "<" & local.outerElement & "\s*", "<" & local.outerElement & " " & local.wireAttributes & " ", "one" );
    }

    /**
     * Get the HTTP response for the component
     * for subsequent requests.
     *
     * @componentPayload struct | The payload to hydrate the component with.
     * @httpRequestState struct | The state of the entire HTTP request being returned for all components.
     *
     * @return struct
     */
    function _getHTTPResponse( componentPayload, httpRequestState ){
        // Hydrate the component
        _hydrate( arguments.componentPayload );
        // Apply any updates
        _applyUpdates( arguments.componentPayload.updates );
        // Apply any calls
        _applyCalls( arguments.componentPayload.calls );
        // Re-validate, silently moving along if it fails
        try {
            validate();
        } catch ( any e ) {}
        /*
            Return the html response first. It's important that we do
            this before calling _getSnapshot() because otherwise any
            child objects will not have been tracked yet.
        */
        local.html = _render();
        // Get snapshot
        local.snapshot = _getSnapshot();
        // Check snapshot for FileUploads, serialize them if found
        local.snapshot.data.each( function( key, value ) {
            if ( isInstanceOf( arguments.value, "FileUpload" ) ) {
                snapshot.data[ arguments.key ] = arguments.value.serializeIt();
            }
            if ( isArray( arguments.value) && arguments.value.len() && isInstanceOf( arguments.value[ 1 ], "FileUpload" ) ) {
                arguments.value.each( function( multiFileUpload, index ) {
                    snapshot.data[ key ][ arguments.index ] = arguments.multiFileUpload.serializeIt();
                } );
            }
        } );

        // Return the HTML response
        local.response = [
            "snapshot": serializeJson( local.snapshot ),
            "effects": {
                "returns": variables._returnValues,
                "html": local.html
            }
        ];
        // Add any dispatches
        if ( variables._dispatches.len() ) {
            local.response.effects[ "dispatches" ] = variables._dispatches;
        }
        // Add any xjs
        if ( variables._xjs.len() ) {
            local.response.effects[ "xjs" ] = variables._xjs;
        }
        // Add any redirects
        if ( variables._redirect.len() ) {
            local.response.effects[ "redirect" ] = variables._redirect;
            local.response.effects[ "redirectUsingNavigate" ] = variables._redirectUsingNavigate;
        }
        // Add any cbwire:scripts
        if ( variables._scripts.count() ) {
            local.response.effects[ "scripts" ] = variables._scripts;
        }
        // Add any cbwire:assets to the global http request state
        if ( variables._assets.count() ) {
            httpRequestState.assets.append( variables._assets );
        }

        return local.response;
    }

    /**
     * Get the snapshot of the component
     *
     * @return struct
     */
    function _getSnapshot() {
        return [
            "data": _getDataProperties(),
            "memo": _getMemo(),
            "checksum": _generateChecksum()
        ];
    }

    /**
     * Generates a computed property that caches the result of the computed method.
     *
     * @name string | The name of the computed property.
     * @method string | The method to compute the property.
     *
     * @return void
     */
    function _generateComputedProperty( name, method ) {
        var nameRef = arguments.name;
        var methodRef = arguments.method;
        variables[ nameRef ] = function( cacheMethod = true ) {
            if ( !variables._cache.keyExists( name ) || !arguments.cacheMethod ) {
                variables._cache[ name ] = methodRef( argumentCollection=arguments );
            }
            return variables._cache[ name ];
        };
        // Do the same for when calling outside the component
        this[nameRef] = function( cacheMethod = true ) {
            if ( !variables._cache.keyExists(nameRef ) || !arguments.cacheMethod ) {
                variables._cache[nameRef] = methodRef( argumentCollection=arguments );
            }
            return variables._cache[nameRef];
        };
    }

    /**
     * Prepare our data properties
     *
     * @return void
     */
    function _prepareDataProperties() {
        if ( !variables.keyExists( "data" ) ) {
            variables.data = [:];
        }

        /*
            Determine our data property names by inspecting
            both the data struct and the components property tags.
        */
        variables._dataPropertyNames = variables.data.reduce( function( acc, key, value ) {
            acc.append( key );
            return acc;
        }, [] );

        /*
            Capture our initial data properties for use in
            calls like reset().
        */
        variables._initialDataProperties = duplicate( _getDataProperties() );
    }

    /**
     * This method will iterate over the component's meta data
     * and prepare any functions labeled as computed for caching.
     *
     * @return void
     */
    function _prepareComputedProperties() {
        /*
            Filter the component's meta data for functions labeled as computed.
            For each computed function, generate a computed property
            that caches the result of the computed function.
        */
        variables._metaData.functions.filter( function( func ) {
            return structKeyExists(func, "computed");
        } ).each( function( func ) {
            _generateComputedProperty( func.name, this[func.name] );
        } );

        /*
            Look for additional computed properties defined in the 'computed'
            variable scope and generate computed properties for each.
        */
        if ( variables.keyExists( "computed" ) ) {
            variables.computed.each( function( key, value ) {
                _generateComputedProperty( key, value );
            } );
        }
    }

    /**
     * Prepares generated getters and setters for data properties.
     * We have to generate these getters and setters when the component
     * initializes AND also check in onMissingMethod to handle the
     * dynamic methods being called either outside or from within the component.
     *
     * @return void
     */
    function _prepareGeneratedGettersAndSetters() {
        /*
            Determine our data property names by inspecting
            both the data struct and the components property tags.
        */
        var dataPropertyNames = variables._dataPropertyNames;

        /*
            Loop over our data property names and generate
            getters and setters for each property.
        */
        dataPropertyNames.each( function ( prop ) {
            if ( !variables.keyExists( "get" & prop ) ) {
                variables[ "get" & prop ] = function() {
                    return variables.data[ prop ];
                }
            }
            if ( !variables.keyExists( "set" & prop ) ) {
                variables[ "set" & prop ] = function( value ) {
                    return variables.data[ prop ] = value;
                }
            }
        } );
    }

    /**
     * Prepares the component for isolation.
     *
     * @return void
     */
    function _prepareIsolation() {
        // If the component has an isolate method, call it
        variables._isolate = variables.keyExists( "isolate" ) && isBoolean( variables.isolate ) && variables.isolate ?
            true : false;
    }

    /**
     * Prepares the component for lazy loading.
     *
     * @return void
     */
    function _prepareLazyLoading() {
        // If the component has a lazyLoad method, call it
        variables._lazyLoad = variables.keyExists( "lazyLoad" ) && isBoolean( variables.lazyLoad ) && variables.lazyLoad ?
            true : false;

        if ( variables._lazyLoad ) {
            variables._isolate = true;
        }
    }

    /**
     * Prepares the component for listening to events.
     *
     * @return void
     */
    function _prepareListeners() {
        /*
            listers = {
                'eventName': 'methodName'
            }
        */
        if ( !variables.keyExists( "listeners" ) ) {
            variables.listeners = [:];
        }

        // Loop through the listeners and check the methods exists, throw error if not
        // TODO: add tests (having issues getting testbox to assert this error)
        variables.listeners.each( function( key, value ) {
            if ( !variables.keyExists( arguments.value ) ) {
                throw( type="CBWIREException", message="The listener '#arguments.key#' references a method '#arguments.value#' but this method does not exist. Please implement '#arguments.value#()' on your component." );
            }
        } );
    }

    /**
     * Returns the path to the view template file.
     */
    function _getViewPath(){
        if ( isModulePath() ) {
            var moduleRoot = variables._CBWIREController.getModuleRootPath( _getModuleName() );
            return moduleRoot & ".wires." & _getComponentName().listFirst( "@" );
        }

        return "wires." & variables._path;
    }

    /**
     * Returns the module name.
     *
     * @return string
     */
    function _getModuleName() {
        return variables._path contains "@" ? variables._path.listLast( "@" ) : "";
    }

    /**
     * Returns the data properties and their values.
     *
     * @return struct
     */
    function _getDataProperties(){
        return variables.data.reduce( function( acc, key, value ) {
            if ( isBoolean( variables.data[ key ] ) && !isNumeric( variables.data[ key ] ) ) {
                acc[ key ] = variables.data[ key ] ? true : false;
            } else {
                acc[ key ] = variables.data[ key ];
            }
            return acc;
        }, [:] );
    }

    /**
     * Returns the component's memo data.
     *
     * @return struct
     */
    function _getMemo(){
        return [
            "id": variables._id,
            "name": _getComponentName(),
            "path": _getComponentName(),
            "method":"GET",
            "children": variables._children.count() ? variables._children : [],
            "scripts": variables._scripts.count() ? variables._scripts.keyArray() : [],
            "assets": variables._assets.count() ? variables._assets.keyArray() : [],
            "isolate": variables._isolate,
            "lazyLoaded": false,
            "lazyIsolated": true,
            "errors":[],
            "locale":"en"
        ]
    }

    /**
     * Returns the component's name.
     *
     * @return string

     */
    function _getComponentName(){
        if ( variables._metaData.name contains "cbwire.models.tmp." ) {
            return variables._metaData.name.replaceNoCase( "cbwire.models.tmp.", "", "one" );
        }
        // only returns the last part of the name seprate by dots
        return variables._path;
    }

    /**
     * Take an incoming rendering and determine the outer component tag.
     * <div>...</div> would return 'div'
     *
     * @rendering string | The rendering to parse.
     *
     * @return string
     */
    function _getComponentTag( rendering ){
        var tag = "";
        var regexMatches = reFindNoCase( "^<([a-zA-Z0-9]+)", arguments.rendering.trim(), 1, true );
        if ( regexMatches.match.len() == 2 ) {
            return regexMatches.match[ 2 ];
        }
        throw( type="CBWIREException", message="Cannot determine component tag." );
    }

    /**
     * Returns a generated key for the component.
     *
     * @return string
     */
    function _generateWireKey(){
        return variables._id & "-" & variables._children.count();
    }

    /**
     * Returns the component's script tags.
     *
     * @return struct
     */
    function _getScripts(){
        return variables._scripts;
    }

    /**
     * Returns the component's meta data.
     *
     * @return struct
     */
    function _getMetaData(){
        return variables._metaData;
    }

    /**
     * Returns the validation result.
     *
     * @return ValidationResult
     */
    function _getValidationResult(){
        return variables._validationResult;
    }

    /**
     * Returns the wire:effects attribute contents.
     *
     * @return string
     */
    function _generateWireEffectsAttribute() {
        local.effects = {};
        local.listenersAsArray = variables.listeners.reduce( function( acc, key, value ) {
            acc.append( key );
            return acc;
        }, [] );
        if ( local.listenersAsArray.len() ) {
            local.effects[ "listeners" ] = local.listenersAsArray;
        }
        if ( variables._scripts.count() ) {
            local.effects[ "scripts" ] = variables._scripts;
        }
        if ( local.effects.count() ) {
            return _encodeAttribute( serializeJson( local.effects ) );
        }
        return "[]";
    }

    /**
     * Response for actually starting rendering of a component.
     */
    function _render( rendering ) {
        local.trimmedHTML = isNull( arguments.rendering ) ? trim( onRender() ) : trim( arguments.rendering );
        // Validate the HTML content to ensure it has a single outer element
        _validateSingleOuterElement( local.trimmedHTML);
        // If this is the initial load, encode the snapshot and insert Livewire attributes
        if ( variables._initialLoad ) {
            // Encode the snapshot for HTML attribute inclusion and process the view content
            local.snapshotEncoded = _encodeAttribute( serializeJson( _getSnapshot() ) );
            return _insertInitialLivewireAttributes( local.trimmedHTML, local.snapshotEncoded, variables._id );
        } else {
            // Return the trimmed HTML content
            return _insertSubsequentLivewireAttributes( local.trimmedHTML );
        }
    }

    /**
     * Returns the first outer element from the provided html.
     * "<div x-data=""></div>" returns "div";
     *
     * @return string
     */
    function _getOuterElement( html ) {
        local.outerElement = reMatchNoCase( "<[A-Za-z]+\s*", arguments.html ).first();
        local.outerElement = local.outerElement.replaceNoCase( "<", "", "one" );
        return local.outerElement.trim();
    }

    /**
     * Returns true if the path contains a module.
     *
     * @return boolean
     */
    function isModulePath() {
        return variables._path contains "@";
    }

    /**
     * Returns true if the cbvalidation module is installed.
     *
     * @return boolean
     */
    function _isCBValidationInstalled() {
        try {
            _getValidationManager();
            return true;
        } catch ( any e ) {
            return false;
        }
    }

    /**
     * Returns true if trimStringValues is enabled, either globally
     * or for the component.
     *
     * @return boolean
     */
    function shouldTrimStringValues() {
        return
            ( _globalSettings.keyExists( "trimStringValues" ) && _globalSettings.trimStringValues == true ) ||
            ( variables.keyExists( "trimStringValues" ) && variables.trimStringValues == true );
    }
}
