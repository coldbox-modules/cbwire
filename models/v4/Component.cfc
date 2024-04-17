component accessors="true" {

    property name="wirebox" inject="wirebox";

    property name="_id";
    property name="_initialLoad" default="true";
    property name="_initialDataProperties";
    property name="_dataPropertyNames";
    property name="_params";
    property name="_key";
    property name="_httpRequestData";
    property name="_metaData";
    property name="_dispatches";
    property name="_cache"; // internal cache for storing data
    property name="data"; // Used for backwards compatibility
    property name="args"; // Used for backwards compatibility

    /**
     * Initializes the component, setting a unique ID if not already set.
     * This method should be called by any extending component's init method if overridden.
     * Extending components should invoke super.init() to ensure the base initialization is performed.
     * @return The initialized component instance.
     */
    function init() {
        if (len(trim(get_Id())) == 0) {
            set_Id(createUUID());
        }
        set_Params( {} );
        set_Key( "" );
        set_HttpRequestData( {} );
        set_Cache( {} );
        set_Dispatches( [] );
        
        /*
            Create a reference to the variables scope called 
            'data' to preserve backwards compatibility with
            prior versions of CBWIRE.
        */
        //setData( variables );
        
        /* 
            Create a reference to the variables scope called
            'args' to preserve backwards compatibility with
            prior versions of CBWIRE.
        */
        setArgs( variables );
        
        /* 
            Cache the component's meta data on initialization
            for fast access where needed.
        */
        set_MetaData( getMetaData( this ) );

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

        return this;
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
     * Passes params to the component to be used with onMount.
     *
     * @return Component
     */
    function _withParams( params ) {
        set_Params( arguments.params );

        // Fire onMount if it exists
        if (structKeyExists(this, "onMount")) {
            onMount( params=arguments.params );
        } else {
            // Loop over our params and set them as variables
            arguments.params.each( function( key, value ) {
                variables[ key ] = value;
            } );
        }

        return this;
    }

    /**
     * Passes HTTP request data to the component to be used with onMount.
     * This method is useful for passing request data to the component for use in rendering.
     * 
     * @param httpRequestData A struct containing the HTTP request data.
     * @return Component
     */
    function _withHTTPRequestData( httpRequestData ) {
        set_HttpRequestData( arguments.httpRequestData );
        return this;
    }

    /**
     * Passes a key to the component to be used to identify the component
     * on subsequent requests.
     *
     * @return Component
     */
    function _withKey( key ) {
        set_Key( arguments.key );

        return this;
    }

    /**
     * Hydrate the component
     * 
     * @param componentPayload A struct containing the payload to hydrate the component with.
     * @return void
     */
    function _hydrate( componentPayload ) {
        // Set our component's id to the incoming memo id
        set_Id( arguments.componentPayload.snapshot.memo.id );

        // Loop over the data and set the variables
        arguments.componentPayload.snapshot.data.each( function( key, value ) {
            if ( variables.keyExists( key ) ) {
                variables[ key ] = value;
            }
        } );
    }

    /**
     * Apply updates to the component
     */
    function _applyUpdates( updates ) {
        arguments.updates.each( function( key, value ) {
            variables[ key ] = value;
        } );
    }

    /**
     * Apply calls to the component
     * 
     * @param calls A struct containing the calls to apply to the component.
     * @return void
     */
    function _applyCalls( calls ) {
        arguments.calls.each( function( call ) {
            invoke( this, call.method, call.params );
        } );
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
        if ( get_initialLoad() ) {
            // Encode the snapshot for HTML attribute inclusion and process the view content
            var snapshotEncoded = _encodeAttribute( serializeJson( _getSnapshot() ) );
            return _insertInitialLivewireAttributes( trimmedHTML, snapshotEncoded, get_Id() );
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
        return getWirebox().getInstance( argumentCollection=arguments );
    }

    /**
     * Captures a dispatch to be executed later
     * by the browser.
     * 
     * @method string | The method to dispatch.
     * @params struct | The parameters to dispatch.
     *
     * @return void
     */
    function dispatch( method, params = {} ) {
        // Convert params to an array first
        var paramsAsArray = params.reduce( function( agg, key, value ) {
            agg.append( value );
            return agg;
        }, [] );
        // Append the dispatch to our dispatches array
        get_Dispatches().append( { "name": arguments.method, "params": paramsAsArray } );
    }

    /**
     * Returns the normalized view path.
     *
     * @viewPath string | The dot notation path to the view template to be rendered, without the .cfm extension.
     * @return string
     */
    private function _getNormalizedViewPath( viewPath ) {
        // Replace all dots with slashes to normalize the path
        var normalizedPath = replace( arguments.viewPath, ".", "/", "all");
        // Check if ".cfm" is present; if not, append it.
        if (not findNoCase(".cfm", normalizedPath)) {
            normalizedPath &= ".cfm";
        }
        // Ensure the path starts with "/wires/" without duplicating it
        if (left(normalizedPath, 6) != "wires/") {
            normalizedPath = "wires/" & normalizedPath;
        }
        // Prepend a leading slash if not present
        if (left(normalizedPath, 1) != "/") {
            normalizedPath = "/" & normalizedPath;
        }

        return normalizedPath;
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
        var meta = get_MetaData();

        /* 
            Handle generated getters and setters for data properties.
            You see we are also preparing the getters and setters in the init method.
            This is provide access to the dynamic methods both from outside 
            the component as well as from within the component.
        */
        if ( arguments.missingMethodName.reFindNoCase( "^get[A-Z].*" ) ) {
            var propertyName = arguments.missingMethodName.reReplaceNoCase( "^get", "" );
            if ( variables.keyExists( propertyName ) ) {
                return variables[ propertyName ];
            }
        }

        if ( arguments.missingMethodName.reFindNoCase( "^set[A-Z].*" ) ) {
            var propertyName = arguments.missingMethodName.reReplaceNoCase( "^set", "" );
            variables[ propertyName ] = arguments.missingMethodArguments[ 1 ];
            return;
        }

        /* 
            Throw an exception if the missing method is not a computed property.
        */
        throw( type="MissingMethodException", message="The method '#arguments.missingMethodName#' does not exist." );
    }

    /**
     * Generates a checksum for securing the component's data.
     *
     * @return String The generated checksum.
     */
    private function _generate_checksum() {
        return "f9f66fa895026e389a10ce006daf3f59afaec8db50cdb60f152af599b32f9192";
        var secretKey = "YourSecretKey"; // This key should be securely retrieved
        return hash(serializeJson(arguments.snapshot) & secretKey, "SHA-256");
    }

    /**
     * Encodes a given string for safe usage within an HTML attribute.
     *
     * @param value The string to be encoded.
     * @return String The encoded string suitable for HTML attribute inclusion.
     */
    private function _encodeAttribute( value ) {
        return arguments.value.replaceNoCase( '"', "&quot;", "all" );
        // return encodeForHTMLAttribute(arguments.value);
    }

    /**
     * Inserts Livewire-specific attributes into the given HTML content, ensuring Livewire can manage the component.
     *
     * @param html The original HTML content to be processed.
     * @param snapshotEncoded The encoded snapshot data for Livewire's consumption.
     * @param id The component's unique identifier.
     * @return String The HTML content with Livewire attributes properly inserted.
     */
    private function _insertInitialLivewireAttributes( html, snapshotEncoded, id ) {
        var livewireAttributes = ' wire:snapshot="' & arguments.snapshotEncoded & '" wire:effects="[]" wire:id="Z1Ruz1tGMPXSfw7osBW2"';
        
        // Insert attributes into the opening tag
        return replaceNoCase( arguments.html, ">", livewireAttributes & ">", "one" );
    }

    /**
     * Inserts subsequent Livewire-specific attributes into the given HTML content.
     * 
     * @html The original HTML content to be processed.
     * 
     * @return String The HTML content with Livewire attributes properly inserted.
     */
    private function _insertSubsequentLivewireAttributes( html ) {
        var livewireAttributes = " wire:id=""#get_Id()#""";
        return replaceNoCase( arguments.html, ">", livewireAttributes & ">", "one" );
    }
    
    /**
     * Renders the content of a view template file.
     * This method is used internally by the view method to render the content of a view template.
     * @param normalizedPath The normalized path to the view template file.
     * @return The rendered content of the view template.
     */
    private function _renderViewContent( normalizedPath, params = {} ){
        
        /* 
            Take any params passed to the view method and make them available as variables
            within the view template. This allows for dynamic content to be rendered based on
            the parameters passed to the view method.
        */
        params.each( function( key, value ) {
            variables[ key ] = value;
        } );

        var viewContent = "";
        savecontent variable="viewContent" {
            // The leading slash in the include path might need to be removed depending on your server setup
            // or application structure, as cfinclude paths are relative to the application root.
            include "#arguments.normalizedPath#"; // Dynamically includes the CFML file for processing.
        }
        return viewContent;
    }

    /**
     * Validates that the HTML content has a single outer element.
     * Ensures the first and last tags match and that the total number of tags is even.
     *
     * @param trimmedHtml The trimmed HTML content to validate.
     * @throws ApplicationException When the HTML does not meet the single outer element criteria.
     */
    private function _validateSingleOuterElement( trimmedHtml ) {
        return; // Skip validation for now
        // Load Jsoup and parse the HTML content
        var jsoup = createObject("java", "org.jsoup.Jsoup");
        var doc = jsoup.parse(trimmedHtml);
        var body = doc.body();
        
        // Jsoup treats both text nodes and element nodes as Elements, so filter only for element nodes
        var elements = body.children();
        var count = 0;

        // Iterate over child elements of the body, counting non-script elements
        for (var element in elements) {
            if (!element.tagName().equalsIgnoreCase("script")) {
                count++;
            }
        }

        // If more than one non-script child element is found, throw an exception
        if (count > 1) {
            throw("ApplicationException", "Multiple root elements detected.");
        }
    }

    /**
     * Get the HTTP response for the component
     * for subsequent requests.
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
        // Return the HTML response
        var response = {
            "snapshot": serializeJson( _getSnapshot() ),
            "effects": {
                "returns": [
                    javaCast( "null", 0 )
                ],
                "html": renderIt()
            }
        };
        // Add any dispatches
        if ( get_Dispatches().len() ) {
            response.effects["dispatches"] = get_Dispatches();
        }

        return response;
    }

    /**
     * Get the snapshot of the component
     * 
     * @return struct
     */
    function _getSnapshot() {
        return {
            "data": _getDataProperties(),
            "memo": _getMemo(),
            "checksum": _generate_checksum()
        };
    }

    /**
     * Indicate that this component is being loaded from subsequent requests.
     * 
     * @return void
     */
    function _asSubsequentRequest(){
        set_InitialLoad( false );
        return this;
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
			_getDataProperties().each( function( key, value ){
				reset( key );
			} );
		} else if ( isArray( arguments.property ) ) {
			// Reset each property in our array individually
			arguments.property.each( function( prop ){
				reset( prop );
			} );
		} else {
			var initialState = get_initialDataProperties();
			// Reset individual property
            variables[ arguments.property ] = initialState[ arguments.property ];
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
     * Generates a computed property that caches the result of the computed method.
     * 
     * @param name The name of the computed property.
     * @param method The method to compute the property.
     * @return void
     */
    private function _generateComputedProperty( name, method ) {
        var computedPropName = arguments.name;
        var computedMethodRef = arguments.method;
        variables[computedPropName] = function( cacheMethod = true ) {
            if ( !variables._cache.keyExists(computedPropName ) || !arguments.cacheMethod ) {
                variables._cache[computedPropName] = computedMethodRef( argumentCollection=arguments );
            }
            return variables._cache[computedPropName];
        };
        // Do the same for when calling outside the component
        this[computedPropName] = function( cacheMethod = true ) {
            if ( !variables._cache.keyExists(computedPropName ) || !arguments.cacheMethod ) {
                variables._cache[computedPropName] = computedMethodRef( argumentCollection=arguments );
            }
            return variables._cache[computedPropName];
        };
    }

    /**
     * Prepare our data properties
     */
    private function _prepareDataProperties() {

        if ( variables.keyExists( "data" ) ) {
            /*
                Copy any data properties defined using 
                'data.' into our variables scope.
            */
            variables.append( data );
        } else {
            variables.data = {};
        }

        /*
            Determine our data property names by inspecting
            both the data struct and the components property tags.
        */
        var names = [];
        data.each( function( key, value ) {
            names.append( key );
        } );

        get_metaData().properties
            .filter( function( prop ) {
                return !prop.keyExists( "inject" );
            } )
            .each( function( prop ) {
                names.append( prop.name );
            } );

        set_dataPropertyNames( names );

        /*
            Capture our initial data properties for use in
            calls like reset().
        */
        set_initialDataProperties( duplicate( _getDataProperties() ) );
    }
     
    /**
     * This method will iterate over the component's meta data
     * and prepare any functions labeled as computed for caching.
     *
     * @return void
     */
    private function _prepareComputedProperties() {
        /* 
            Filter the component's meta data for functions labeled as computed.
            For each computed function, generate a computed property
            that caches the result of the computed function.
        */
        get_MetaData().functions.filter( function( func ) {
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
    private function _prepareGeneratedGettersAndSetters() {
        /* 
            Determine our data property names by inspecting
            both the data struct and the components property tags.
        */
        var dataPropertyNames = get_DataPropertyNames();

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
     * Returns the path to the view template file.
     */
    private function _getViewPath(){
        return "wires." & _getComponentName();
    }

    /**
     * Returns the data properties and their values.
     * 
     * @return struct
     */
    private function _getDataProperties(){
        return get_dataPropertyNames().reduce( function( acc, key, value ) {
            if ( isBoolean( variables[ key ] ) && !isNumeric( variables[ key ] ) ) {
                acc[ key ] = variables[ key ] ? true : false;
            } else {
                acc[ key ] = variables[ key ];
            }
            return acc;
        }, {} );
    }

    /**
     * Returns the component's memo data.
     * 
     * @return struct
     */
    private function _getMemo(){
        var name = _getComponentName();
        return {
            "id":"Z1Ruz1tGMPXSfw7osBW2",
            "name":name,
            "path":name,
            "method":"GET",
            "children":[],
            "scripts":[],
            "assets":[],
            "errors":[],
            "locale":"en"
        }
    }

    /**
     * Returns the component's name.
     * 
     * @return string
     
     */
    private function _getComponentName(){
        return getMetaData().name.replaceNoCase( "wires.", "", "one" );
    }
}
