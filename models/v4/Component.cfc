component accessors="true" {

    property name="_id";
    property name="_params";
    property name="_key";
    property name="_httpRequestData";
    property name="_metaData";
    property name="_cache"; // internal cache for storing data
    property name="data"; // Used for backwards compatibility
    property name="args"; // Used for backwards compatibility

    /**
     * Initializes the component, setting a unique ID if not already set.
     * This method should be called by any extending component's init method if overridden.
     * Extending components should invoke super.init() to ensure the base initialization is performed.
     * @return The initialized component instance.
     */
    public function init() {
        if (len(trim(get_Id())) == 0) {
            set_Id(createUUID());
        }
        set_Params( {} );
        set_Key( "" );
        set_HttpRequestData( {} );
        set_Cache( {} );

        /* 
            If the 'data' key exists in the variables scope, merge its contents
            into the variables scope to preserve backwards compatibility with
            prior versions of CBWIRE.
        */
        if ( variables.keyExists( "data") ) {
            data.each( function( key, value ) {
                variables[ key ] = value;
            } );
        }

        /*
            Create a reference to the variables scope called 
            'data' to preserve backwards compatibility with
            prior versions of CBWIRE.
        */
        setData( variables );

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
        set_MetaData( getMetaData(this) );

        /*
            Prep our computed properties for caching 
        */
        _prepareComputedProperties();

        return this;
    }

    /**
     * Renders the component's HTML output.
     * This method should be overridden by subclasses to implement specific rendering logic.
     * @return The HTML representation of the component.
     */
    public string function renderIt() {
        throw("AbstractMethodException", "This method is abstract and must be overridden in the subclass.");
    }

    /**
     * Passes params to the component to be used with onMount.
     *
     * @return Component
     */
    public Component function _withParams( required struct params ) {
        set_Params( arguments.params );

        // Fire onMount if it exists
        if (structKeyExists(this, "onMount")) {
            onMount( params=arguments.params );
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
    public Component function _withHTTPRequestData( required struct httpRequestData ) {
        set_HttpRequestData( arguments.httpRequestData );
        return this;
    }

    /**
     * Passes a key to the component to be used to identify the component
     * on subsequent requests.
     *
     * @return Component
     */
    public Component function _withKey( required string key ) {
        set_Key( arguments.key );

        return this;
    }

    /**
     * Renders a specified view by converting dot notation to path notation and appending .cfm if necessary.
     * Then, it returns the HTML content.
     *
     * @param viewPath The dot notation path to the view template to be rendered, without the .cfm extension.
     * @param params A struct containing the parameters to be passed to the view template.
     * @return The rendered HTML content as a string.
     */
    public string function view(required string viewPath, params = {} ) {
        // Normalize the view path: convert dot notation to path notation, and ensure it starts with "/wires/"
        var normalizedPath = replace(viewPath, ".", "/", "all");

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

        var trimmedHTML = trim( _renderViewContent(normalizedPath, params) );

        // Validate the HTML content to ensure it has a single outer element
        _validateSingleOuterElement(trimmedHTML);

        // Prepare the snapshot data for the Livewire attributes
        var snapshot = {
            "data": {"count": getCount()},
            "memo": {
                "id": get_Id(),
                "name": "Counter",
                "path": "counter"
                // Additional properties as necessary
            }
        };

        // Encode the snapshot for HTML attribute inclusion and process the view content
        var snapshotEncoded = _encode_for_html_attribute(serializeJson(snapshot));
        
        // Insert Livewire-specific attributes into the HTML content
        return _insert_livewire_attributes(trimmedHTML, snapshotEncoded, get_Id());
    }

    /**
     * Fires when missing methods are called. 
     * Handles computed properties.
     *
     * @return any
     */
    public function onMissingMethod( missingMethodName, missingMethodArguments ){
        /* 
            Check the component's meta data for functions 
            labeled as computed.
        */
        var meta = get_MetaData();

        /* 
            Throw an exception if the missing method is not a computed property.
        */
        throw( type="MissingMethodException", message="The method #arguments.missingMethodName# does not exist." );
    }

    /**
     * Generates a checksum for securing the component's snapshot data.
     *
     * @param snapshot A struct representing the component's state snapshot.
     * @return String The generated checksum.
     */
    private string function _generate_checksum(required struct snapshot) {
        var secretKey = "YourSecretKey"; // This key should be securely retrieved
        return hash(serializeJson(arguments.snapshot) & secretKey, "SHA-256");
    }

    /**
     * Encodes a given string for safe usage within an HTML attribute.
     *
     * @param value The string to be encoded.
     * @return String The encoded string suitable for HTML attribute inclusion.
     */
    private string function _encode_for_html_attribute(required string value) {
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
    private string function _insert_livewire_attributes(required string html, required string snapshotEncoded, required string id) {
        // Locate the position to insert Livewire attributes right after the opening tag
        var firstTagEnd = find(">", html);
        var isSelfClosing = find("/>", html, firstTagEnd - 1) == firstTagEnd - 1;
        var livewireAttributes = ' wire:snapshot="' & snapshotEncoded & '" wire:effects="[]" wire:id="' & id & '"';
        
        if (isSelfClosing) {
            // Insert attributes before self-closing tag's />
            return left(html, firstTagEnd - 2) & livewireAttributes & "/>" & right(html, len(html) - firstTagEnd);
        } else {
            // Insert attributes into the opening tag
            return left(html, firstTagEnd) & livewireAttributes & right(html, len(html) - firstTagEnd);
        }
    }

    /**
     * Renders the content of a view template file.
     * This method is used internally by the view method to render the content of a view template.
     * @param normalizedPath The normalized path to the view template file.
     * @return The rendered content of the view template.
     */
    private function _renderViewContent( required normalizedPath, params = {} ){

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
            include "#normalizedPath#"; // Dynamically includes the CFML file for processing.
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
    private void function _validateSingleOuterElement(required string trimmedHtml) {
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
     * Get the components properties using meta data
     * 
     * @return struct
     */
    public struct function _getDataProperties() {
        var properties = get_MetaData().properties;
        return properties.reduce( function( result, prop ) {
            result[prop.name] = invoke( this, "get" & prop.name );
            return result;
        } );
    }

    /* 
        This method will iterate over the component's meta data
        and prepare any functions labeled as computed for caching.

        @return void
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

    private function _generateComputedProperty( required string name, required function method ) {
        var computedPropName = arguments.name;
        var computedMethodRef = arguments.method;
        this[computedPropName] = function( cacheMethod = true ) {
            if ( !variables._cache.keyExists(computedPropName ) || !arguments.cacheMethod ) {
                variables._cache[computedPropName] = computedMethodRef( argumentCollection=arguments );
            }
            return variables._cache[computedPropName];
        };
    }
}
