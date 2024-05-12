component output="true" {

    property name="_CBWIREController" inject="CBWIREController@cbwire";

    property name="_wirebox" inject="wirebox";

    property name="_id";
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

    /**
     * Initializes the component, setting a unique ID if not already set.
     * This method should be called by any extending component's init method if overridden.
     * Extending components should invoke super.init() to ensure the base initialization is performed.
     * 
     * @return The initialized component instance.
     */
    function init() {
        if ( isNull( variables._id ) ) {
            variables._id = hash( createUUID() );
        }

        variables._params = [:];
        variables._key = "";
        variables._cache = [:];
        variables._dispatches = [];
        variables._children = [:];
        variables._initialLoad = true;
        variables._lazyLoad = false;
        variables._lazyIsolated = true;
        variables._xjs = [];
        variables._returnValues = [];
        
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
            Prep for lazy loading
        */
        _prepareLazyLoading();

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
     * @viewPath string | The dot notation path to the view template to be rendered, without the .cfm extension.
     * @params struct | A struct containing the parameters to be passed to the view template.
     *
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
     * and then calls its internal renderIt() method.
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
                ._withParent( this )
                ._withEvent( variables._event )
                ._withParams( arguments.params, arguments.lazy )
                ._withKey( arguments.key )
                ._withLazy( arguments.lazy );

        // Check if lazy loading is enabled
        if ( arguments.lazy ) {
            return local.instance._generateXIntersectLazyLoadSnapshot( params=arguments.params );
        } else {
            // Render it out normally
            local.rendering = local.instance.renderIt();
            // Based on the rendering, determine our outer component tag
            local.componentTag = _getComponentTag( local.rendering );
            // Track the rendered child
            variables._children.append( [
                "#arguments.key#": [
                    local.componentTag,
                    local.instance._getId()
                ]
            ] );

            return local.instance.renderIt();
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
     * @return ValidationResult
     * 
     * @throws ValidationException
     */
    function validateOrFail(
        target,
		fields        = "*",
		constraints   = {},
		locale        = "",
		excludeFields = "",
		includeFields = "",
		profiles      = ""
    ){
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
    function hasErrors( field ) {
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
     * Passes the current event into our component.
     * 
     * @return Component
     * 
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

        // Fire onMount if it exists
        onMount( 
            event=variables._event,
            rc=variables._event.getCollection(),
            prc=variables._event.getPrivateCollection(),    
            params=arguments.params         
        );


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
    }

    /**
     * Apply updates to the component
     * 
     * @updates struct | A struct containing the updates to apply to the component.
     * 
     * @return void
     */
    function _applyUpdates( updates ) {
        arguments.updates.each( function( key, value ) {
            variables.data[ key ] = value;
        } );
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
        // Check if ".cfm" is present; if not, append it.
        if (not findNoCase(".cfm", local.normalizedPath)) {
            local.normalizedPath &= ".cfm";
        }
        // Ensure the path starts with "/wires/" without duplicating it
        if (left(local.normalizedPath, 6) != "wires/") {
            local.normalizedPath = "wires/" & local.normalizedPath;
        }
        // Prepend a leading slash if not present
        if (left(local.normalizedPath, 1) != "/") {
            local.normalizedPath = "/" & local.normalizedPath;
        }

        return local.normalizedPath;
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
    function _finishUpload( prop, params, self ) {
        local.fileUpload = new FileUpload(
            wire = this,
            dataPropertyName = arguments.params[ 1 ]
        );
        // Dispatch the upload URL
        dispatchSelf(
            event="upload:finished",
            params=[
                "name"=arguments.prop,
                "params"=arguments.params
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
        var livewireAttributes = ' wire:snapshot="' & arguments.snapshotEncoded & '" wire:effects="[]" wire:id="#variables._id#"';
        
        // Insert attributes into the opening tag
        return replaceNoCase( arguments.html, ">", livewireAttributes & ">", "one" );
    }

    /**
     * Inserts subsequent Livewire-specific attributes into the given HTML content.
     * 
     * @html string | The original HTML content to be processed.
     * 
     * @return String The HTML content with Livewire attributes properly inserted.
     */
    function _insertSubsequentLivewireAttributes( html ) {
        var livewireAttributes = " wire:id=""#variables._id#""";
        return replaceNoCase( arguments.html, ">", livewireAttributes & ">", "one" );
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
        // Render our view using an renderer encapsulator
        savecontent variable="local.viewContent" {
            cfmodule(
                template = "RendererEncapsulator.cfm",
                cbwireComponent = this,
                normalizedPath = arguments.normalizedPath,
                params = arguments.params
            );
        }

        return local.viewContent;
    }

    /**
     * Validates that the HTML content has a single outer element.
     * Ensures the first and last tags match and that the total number of tags is even.
     *
     * @trimmedHtml string | The trimmed HTML content to validate.
     * @throws ApplicationException When the HTML does not meet the single outer element criteria.
     */
    function _validateSingleOuterElement( trimmedHtml ) {
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
        var lazyLoadSnapshot = serializeJson(local.snapshot);
    
        // Generate the base64 encoded version of the serialized snapshot for use in x-intersect
        var base64EncodedSnapshot = toBase64(lazyLoadSnapshot);   

        // Build the final <div> element with appropriate attributes
        var lazyLoadDiv = '<div wire:snapshot="' & _encodeAttribute( serializeJson( _getSnapshot() ) ) & '" ' &
                          'wire:effects="[]" wire:id="#variables._id#" ' &
                          'x-intersect="$wire._lazyMount(&##039;' & base64EncodedSnapshot & '&##039;)">#placeHolder()#</div>';
    
        return lazyLoadDiv;
    }

    /**
     * Get the HTTP response for the component
     * for subsequent requests.
     * 
     * @componentPayload struct | The payload to hydrate the component with.
     * 
     * @return struct
     */
    function _getHTTPResponse( componentPayload ){

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
        var html = renderIt();
        // Return the HTML response
        var response = [
            "snapshot": serializeJson( _getSnapshot() ),
            "effects": {
                "returns": variables._returnValues,
                "html": html
            }
        ];
        // Add any dispatches
        if ( variables._dispatches.len() ) {
            response.effects["dispatches"] = variables._dispatches;
        }
        // Add any xjs
        if ( variables._xjs.len() ) {
            response.effects["xjs"] = variables._xjs;
        }

        return response;
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
                    return variables[ prop ];
                }
            }
            if ( !variables.keyExists( "set" & prop ) ) {
                variables[ "set" & prop ] = function( value ) {
                    return variables[ prop ] = value;
                }
            }
        } );
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
    }

    /**
     * Returns the path to the view template file.
     */
    function _getViewPath(){
        return "wires." & _getComponentName();
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
        var name = _getComponentName();
        return [
            "id": variables._id,
            "name":name,
            "path":name,
            "method":"GET",
            "children": variables._children.count() ? variables._children : [],
            "scripts":[],
            "assets":[],
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
        return variables._metaData.name.replaceNoCase( "wires.", "", "one" );
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
}
