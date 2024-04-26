component {

    property name="_CBWIREController" inject="CBWIREController@cbwire";

    property name="_wirebox" inject="wirebox";

    property name="_id";
    property name="_parent";
    property name="_initialLoad";
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

    /**
     * Initializes the component, setting a unique ID if not already set.
     * This method should be called by any extending component's init method if overridden.
     * Extending components should invoke super.init() to ensure the base initialization is performed.
     * 
     * @return The initialized component instance.
     */
    function init() {
        if ( isNull( variables._id ) ) {
            variables._id = createUUID();
        }

        variables._params = {};
        variables._key = "";
        variables._cache = {};
        variables._dispatches = [];
        variables._children = {};
        variables._initialLoad = true;
        
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

        return this;
    }

    /*
        ==================================================================
        Public API
        ==================================================================
    */
    include "ComponentPublicAPI.cfm";

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
     * @return Component
     */
    function _withParams( params ) {
        variables._params = arguments.params;

        // Fire onMount if it exists
        if (structKeyExists(this, "onMount")) {
            onMount( 
                event=variables._event,
                rc=variables._event.getCollection(),
                prc=variables._event.getPrivateCollection(),    
                params=arguments.params         
            );
        } else {
            // Loop over our params and set them as variables
            arguments.params.each( function( key, value ) {
                variables[ key ] = value;
            } );
        }

        return this;
    }

    /**
     * Passes a key to the component to be used to identify the component
     * on subsequent requests.
     *
     * @return Component
     */
    function _withKey( key ) {
        variables._key = arguments.key;
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
        variables._id = arguments.componentPayload.snapshot.memo.id;
        // Append the incoming data to our component's data
        variables.data.append( arguments.componentPayload.snapshot.data, true );
    }

    /**
     * Apply updates to the component
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
     * @param calls A struct containing the calls to apply to the component.
     * @return void
     */
    function _applyCalls( calls ) {
        arguments.calls.each( function( call ) {
            try {
                invoke( this, call.method, call.params );
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
    private function _getValidationManager(){
        try {
    		return getInstance( dsl="provider:ValidationManager@cbvalidation" );
        } catch ( any e ) {
            throw( type="CBWIREException", message="ValidationManager not found. Make sure the 'cbvalidation' module is installed." );
        }
    }

    /**
     * Returns a struct of cbvalidation constraints.
     * 
     * @return struct
     */
    private function _getConstraints(){
        if ( variables.keyExists( "constraints" ) ) {
            return variables.constraints;
        }
        return {};
    }

    /**
     * Parses the dispatch parameters into an array.
     *
     * @return array
     */
    private function _parseDispatchParams() {
        return arguments
            .filter( function( key, value ) {
                return key != "event";
            } )
            .reduce( function( agg, key, value ) {
                agg.append( value );
                return agg;
            }, [] );
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
    private function _generateChecksum() {
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
        var livewireAttributes = ' wire:snapshot="' & arguments.snapshotEncoded & '" wire:effects="[]" wire:id="#variables._id#"';
        
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
        var livewireAttributes = " wire:id=""#variables._id#""";
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
            Create reference to local scope for the method.
        */
        var localScope = local;
        /* 
            Take our data properties and make them available as variables
            to the view.
        */
        variables.data.each( function( key, value ) {
            localScope[ key ] = value;
        } );

        /* 
            Take any params passed to the view method and make them available as variables
            within the view template. This allows for dynamic content to be rendered based on
            the parameters passed to the view method.
        */
        params.each( function( key, value ) {
            localScope[ key ] = value;
        } );

        // Auto validate whenever rendering the view
        validate();

        // Provide 'validation.' variable to the view
        localScope.validation = variables._validationResult;

        // Provide 'args' scope to the view
        localScope.args = localScope;

        savecontent variable="localScope.viewContent" {
            // The leading slash in the include path might need to be removed depending on your server setup
            // or application structure, as cfinclude paths are relative to the application root.
            include "#arguments.normalizedPath#"; // Dynamically includes the CFML file for processing.
        }
        return localScope.viewContent;
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
        var response = {
            "snapshot": serializeJson( _getSnapshot() ),
            "effects": {
                "returns": [
                    javaCast( "null", 0 )
                ],
                "html": html
            }
        };
        // Add any dispatches
        if ( variables._dispatches.len() ) {
            response.effects["dispatches"] = variables._dispatches;
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
            "checksum": _generateChecksum()
        };
    }

    /**
     * Generates a computed property that caches the result of the computed method.
     * 
     * @param name The name of the computed property.
     * @param method The method to compute the property.
     * @return void
     */
    private function _generateComputedProperty( name, method ) {
        var name = arguments.name;
        var methodRef = arguments.method;
        variables[name] = function( cacheMethod = true ) {
            if ( !variables._cache.keyExists(name ) || !arguments.cacheMethod ) {
                variables._cache[name] = methodRef( argumentCollection=arguments );
            }
            return variables._cache[name];
        };
        // Do the same for when calling outside the component
        this[name] = function( cacheMethod = true ) {
            if ( !variables._cache.keyExists(name ) || !arguments.cacheMethod ) {
                variables._cache[name] = methodRef( argumentCollection=arguments );
            }
            return variables._cache[name];
        };
    }

    /**
     * Prepare our data properties
     * 
     * @return void
     */
    private function _prepareDataProperties() {
        if ( !variables.keyExists( "data" ) ) {
            variables.data = {};
        }

        /*
            Determine our data property names by inspecting
            both the data struct and the components property tags.
        */
        variables._dataPropertyNames = variables.data.reduce( function( acc, key, value ) {
            acc.append( key );
            return acc;
        }, [] );

        variables._metaData.properties
            .filter( function( prop ) {
                return !prop.keyExists( "inject" );
            } )
            .each( function( prop ) {
                variables._dataPropertyNames.append( prop.name );
            } );

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
    private function _prepareComputedProperties() {
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
    private function _prepareGeneratedGettersAndSetters() {
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
        return variables.data.reduce( function( acc, key, value ) {
            if ( isBoolean( variables.data[ key ] ) && !isNumeric( variables.data[ key ] ) ) {
                acc[ key ] = variables.data[ key ] ? true : false;
            } else {
                acc[ key ] = variables.data[ key ];
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
            "id":"#variables._id#",
            "name":name,
            "path":name,
            "method":"GET",
            "children": variables._children.count() ? variables._children : [],
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
        return variables._metaData.name.replaceNoCase( "wires.", "", "one" );
    }

    /**
     * Take an incoming rendering and determine the outer component tag.
     * <div>...</div> would return 'div'
     * 
     * @return string
     */
    private function _getComponentTag( rendering ){
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
    private function _generateWireKey(){
        return variables._id & "-" & variables._children.count();
    }
}
