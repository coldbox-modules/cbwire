/**
 * This is the base object that all cbwire components extend for functionality.
 *
 * Most internal methods and properties here are namespaced with a "$" to avoid collisions
 * with child components.
 */
component {

    // Injected ColdBox Renderer for rendering operations.
    property
        name="$renderer"
        inject="coldbox:renderer";

    // Injected WireBox for dependency injection.
    property
        name="$wirebox"
        inject="wirebox";

    // Injected the wire request that's incoming from the browser.
    property
        name="$wireRequest"
        inject="WireRequest@cbwire";

    // Injected populator.
    property
        name="$populator"
        inject="wirebox:populator";

    // Injected settings.
    property
        name="$settings"
        inject="coldbox:modulesettings:cbwire";


    /**
     * The default data struct for cbwire components.
     * This should be overidden in the child component
     * with data properties.
     */
    variables.data = {};

    /**
     * The default computed struct for cbwire components.
     * This should be overidden in the child component with
     * computed properties.
     */
    variables.computed = {};

    /**
     * Our beautiful, simple constructor.
     *
     * @return Component
     */
    function init(){
        variables.$isInitialRendering = true;
        variables.emits = [];
        return this;
    }

    /**
     * Relocate user browser requests to other events, URLs, or URIs.
     *
     * @event The name of the event to run, if not passed, then it will use the default event found in your configuration file
     * @URL The full URL you would like to relocate to instead of an event: ex: URL='http://www.google.com'
     * @URI The relative URI you would like to relocate to instead of an event: ex: URI='/mypath/awesome/here'
     * @queryString The query string or struct to append, if needed. If in SES mode it will be translated to convention name value pairs
     * @persist What request collection keys to persist in flash ram
     * @persistStruct A structure key-value pairs to persist in flash ram
     * @addToken Wether to add the tokens or not. Default is false
     * @ssl Whether to relocate in SSL or not
     * @baseURL Use this baseURL instead of the index.cfm that is used by default. You can use this for ssl or any full base url you would like to use. Ex: https://mysite.com/index.cfm
     * @postProcessExempt Do not fire the postProcess interceptors
     * @statusCode The status code to use in the relocation
     */
    void function $relocate(
        event,
        URL,
        URI,
        queryString,
        persist,
        struct persistStruct,
        boolean addToken,
        boolean ssl,
        baseURL,
        boolean postProcessExempt,
        numeric statusCode
    ){
        return variables.$renderer.relocate( argumentCollection = arguments );
    }

    /**
     * Returns a 21 character UUID to uniquely identify the component HTML during rendering.
     * The 21 characters matches Livewire JS native implementation.
     *
     * @return String
     */
    function getID(){
        return createUUID()
            .replace( "-", "", "all" )
            .left( 21 );
    }

    /**
     * Returns the initial data of our component, which is ultimately serialized
     * to json and return in the view as our component is first rendered.
     *
     * @renderingHash String | Hash of the view rendering. Used to populate serverMemo.htmlHash in struct response.
     *
     * @return Struct
     */
    function getInitialData( renderingHash = "" ){
        return {
            "fingerprint" : {
                "id" : this.getID(),
                "name" : this.getMeta().name,
                "locale" : "en",
                "path" : this.getPath(),
                "method" : "GET"
            },
            "effects" : { "listeners" : variables.getListenerNames() },
            "serverMemo" : {
                "children" : [],
                "errors" : [],
                "htmlHash" : arguments.renderingHash,
                "data" : this.getState(),
                "dataMeta" : [],
                "checksum" : this.getChecksum(),
                "mountedState" : variables.getMountedState()
            }
        };
    }

    /**
     * Throws an error if renderIt() is not defined on our child class.
     *
     * @return Void
     */
    function renderIt(){
        throw(
            type = "RenderMethodNotFound",
            message = "Couldn't find a renderIt() method defined on the component '#this.getMeta().name#'."
        );
    }

    /**
     * Invokes renderIt() on the cbwire component and caches the rendered
     * results into variables.rendering.
     *
     * @return String
     */
    function getRendering(){
        if ( !structKeyExists( variables, "rendering" ) ){
            variables.rendering = this.renderIt();
        }
        return variables.rendering;
    }

    /**
     * Returns the checksum hash of our current state.
     *
     * @return String
     */
    function getChecksum(){
        return hash( serializeJSON( this.getState() ) );
    }

    /**
     * Returns the current state of our component.
     *
     * @return Struct
     */
    function getState(){
        /**
         * Get our data properties for our current state.
         */
        var state = variables.data;

        if ( structKeyExists( variables, "computed" ) ){
            variables.computed.each( function( key, value ){
                state[ key ] = value;
            } );
        }

        return state;
    }

    /**
     * Returns true if the provided method name can be found on our component.
     *
     * @methodName String | The method name we are checking.
     * @return Boolean
     */
    function hasMethod( required methodName ){
        return structKeyExists( this, arguments.methodName );
    }

    /**
     * Renders our component's view and returns the rendering.
     *
     * @return String
     */
    function renderView(){
        // Pass the properties of the cbwire component as variables to the view
        arguments.args = this.getState();

        // Render our view using coldbox rendering
        var rendering = variables.$renderer.renderView( argumentCollection = arguments );

        // Add properties to top element to make cbwire actually work.
        return variables.applyWiringToOuterElement( rendering );
    }

    /**
     * Fires when the cbwire component is initially created.
     * Looks to see if a mount() method is defined on our component and if so, invokes it.
     *
     * This method is given the $ prefix to avoid collision with the mount method
     * that can be optionally defined on a cbwire component.
     *
     * @parameters Struct of params to bind into the component
     *
     * @return Component
     */
    function $mount( parameters = {} ){
        if ( structKeyExists( this, "mount" ) && isCustomFunction( this.mount ) ){
            this[ "mount" ](
                parameters = arguments.parameters,
                event = variables.$wireRequest.getEvent(),
                rc = variables.$wireRequest.getCollection(),
                prc = variables.$wireRequest.getPrivateCollection()
            );
        } else{
            /**
             * Use setter population to populate our component.
             */
            variables.$populator.populateFromStruct(
                target: this,
                trustedSetter: true,
                memento: arguments.parameters,
                excludes: ""
            );
        }

        // Capture the mounted state
        variables.mountedState = duplicate( this.getState() );

        return this;
    }

    /**
     * Sets an individual data property value, first by using a setter
     * if it exists, and otherwise setting directly to our variables
     * scope.
     *
     * Fires '$preUpdate[prop]' and 'postUpdate[prop]' events on the cbwire component.
     *
     * @propertyName String | Name of the property we are setting
     * @value Any | Value of the property we are settting
     *
     * @return Void
     */
    function $set( propertyName, value ){
        // Invoke '$preUpdate[prop]' event
        this.invokeMethod( methodName = "preUpdate" & arguments.propertyName, propertyName = arguments.value );

        variables.data[ "#arguments.propertyName#" ] = arguments.value;

        // Invoke 'postUpdate[prop]' event
        this.invokeMethod( methodName = "postUpdate" & arguments.propertyName, propertyName = arguments.value );
    }

    /**
     * Returns the URL which is included in the initial data that is rendered
     * with the view.
     *
     * Inspects the cbwire component for properties that should
     * be included in the path
     *
     * @return String
     */
    function getPath(){
        var queryStringValues = variables.getQueryStringValues();

        if ( len( queryStringValues ) ){
            var referer = variables.getHTTPReferer();

            // Strip away any queryString parameters from the referer so
            // we don't duplicate them when we append the queryStringValues below.
            if ( referer contains "?" ){
                referer = listGetAt( referer, 1, "?" );
            }

            return "#referer#?#queryStringValues#";
        }

        // Return empty string by default;
        return "";
    }

    /**
     * Sets the mounted state for our component for the ability to rollback changes.
     *
     * @state Struct
     * @return Void
     */
    function setMountedState( required state ){
        variables.mountedState = arguments.state;
    }

    /**
     * Returns any captured emits that need to be returned
     *
     * @return Array
     */
    function getEmits(){
        return variables.emits;
    }

    /**
     * Returns true if listeners are detected on the component.
     *
     * @return Boolean
     */
    function hasListeners(){
        return arrayLen( variables.getListenerNames() );
    }

    /**
     * Returns the listeners defined on the component.
     * If no listeners are defined, an empty struct is returned.
     *
     * @return Struct
     */
    function getListeners(){
        if ( structKeyExists( variables, "listeners" ) && isStruct( variables.listeners ) ){
            return variables.listeners;
        }
        return {};
    }

    /**
     * Returns the meta data for this component.
     * Ensures that we only run this once.
     *
     * @return Struct
     */
    function getMeta(){
        if ( !structKeyExists( variables, "meta" ) ){
            variables.meta = getMetadata( this );
        }
        return variables.meta;
    }


    /**
     * Invokes a dynamic method on our component. If the method doesn't exist,
     * then it proceeds without error because of onMissingMethod.
     *
     * Returns whatever the method returns.
     *
     * Used mainly with lifecycle hooks.
     *
     * @return Any
     */
    function invokeMethod( required methodName ){

        var parsedArguments = duplicate( arguments );

        structDelete( parsedArguments, "methodName" );

        return invoke(
            this,
            arguments.methodName,
            parsedArguments
        );
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
        this.invokeMethod( "postRefresh" );
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
        trackEmit = true
    ){
        // Invoke 'preEmit' event
        this.invokeMethod(
            methodName = "preEmit",
            eventName = arguments.eventName,
            parameters = arguments.parameters
        );

        // Invoke 'preEmit[EventName]' event
        this.invokeMethod(
            methodName = "preEmit" & arguments.eventName,
            parameters = arguments.parameters
        );

        // Capture the emit as we will need to notify the UI in our response
        if ( arguments.trackEmit ){
            var emitter = createObject( "component", "cbwire.models.emit.BaseEmit" ).init(
                arguments.eventName,
                arguments.parameters
            );

            variables.trackEmit( emitter );
        }

        var listeners = this.getListeners();

        if ( structKeyExists( listeners, eventName ) ){
            var listener = listeners[ eventName ];

            if ( len( arguments.eventName ) && this.hasMethod( listener ) ){
                return this.invokeMethod( listener );
            }
        }

        // Invoke 'postEmit' event
        this.invokeMethod(
            methodName = "postEmit",
            eventName = arguments.eventName,
            parameters = arguments.parameters
        );

        // Invoke 'postEmit[EventName]' event
        this.invokeMethod(
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
        var emitter = createObject( "component", "cbwire.models.emit.EmitSelf" ).init(
            arguments.eventName,
            arguments.parameters
        );

        // Capture the emit as we will need to notify the UI in our response
        variables.trackEmit( emitter );
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
        var emitter = createObject( "component", "cbwire.models.emit.EmitUp" ).init(
            arguments.eventName,
            arguments.parameters
        );

        // Capture the emit as we will need to notify the UI in our response
        variables.trackEmit( emitter );
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
        var emitter = createObject( "component", "cbwire.models.emit.EmitTo" ).init(
            arguments.eventName,
            arguments.componentName,
            arguments.parameters
        );

        // Capture the emit as we will need to notify the UI in our response
        variables.trackEmit( emitter );
    }

    /**
     * Runs if any missing methods are called on our component.
     *
     * Mainly used for component populator using the wirebox populator
     * and trusted setters.
     *
     * @missingMethodName String | Name of the missing method that was called.
     * @missingMethodArguments Struct | The arguments provided to the missing method.
     *
     * @return Void
     */
    function onMissingMethod(
        required missingMethodName,
        required missingMethodArguments
    ){
        if ( reFindNoCase( "^set.+", arguments.missingMethodName ) ){
            // Extract data property name from the setter method called.
            var dataPropertyName = reReplaceNoCase(
                arguments.missingMethodName,
                "^set",
                "",
                "one"
            );

            // Check to see if the data property name is defined in the component.
            var dataPropertyExists = structKeyExists( variables.data, dataPropertyName );

            if ( dataPropertyExists ){
                // Handle variations in missingMethodArguments from wirebox bean populator and our own implemented setters.
                if ( structKeyExists( arguments.missingMethodArguments, "value" ) ){
                    this.$set( dataPropertyName, arguments.missingMethodArguments.value );
                } else {
                    this.$set( dataPropertyName, arguments.missingMethodArguments[ 1 ] );
                }
            } else if (
                structKeyExists( variables.$settings, "throwOnMissingSetterMethod" ) && variables.$settings.throwOnMissingSetterMethod == true
            ){
                throw( type = "WireSetterNotFound", message = "The wire property '#dataPropertyName#' was not found." );
            }
        }
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
        if ( isArray( arguments.property ) ){
            // Reset each property in our array individually
            arguments.property.each( function( prop ){
                this.reset( prop );
            } );
        } else{
            // Reset individual property
            this.$set( arguments.property, variables.getMountedState()[ arguments.property ] );
        }
    }

    /**
     * Gets our mounted state.
     *
     * @return Struct
     */
    private function getMountedState(){
        if ( structKeyExists( variables, "mountedState" ) ){
            return variables.mountedState;
        }
        return {};
    }

    /**
     * Check if there are properties to be included in our query string
     * and assembles them together in a single string to be used within a URL.
     *
     * @return String
     */
    private function getQueryStringValues(){
        // Default with an empty array
        if ( !structKeyExists( variables, "queryString" ) ){
            return "";
        }

        var currentState = this.getState();

        // Handle array of property names
        if ( isArray( variables.queryString ) ){
            var result = variables.queryString.reduce( function( agg, prop ){
                agg &= prop & "=" & currentState[ prop ];
                return agg;
            }, "" );
        } else{
            var result = "";
        }

        return result;
    }

    /**
     * Tracks an emit, which is later returned in our API response and used
     * by cbwire.
     *
     * @emitter cbwire.models.emit.BaseEmit | An instance of an emitter.
     * @return Array;
     */
    private function trackEmit( required emitter ){
        var result = emitter.getResult();
        variables.emits.append( result );
    }

    /**
     * Returns the names of the listeners defined on our component.
     *
     * @return Array
     */
    private function getListenerNames(){
        return structKeyList( this.getListeners() ).listToArray();
    }

    /**
     * Apply cbwire attribute to the outer element in the provided rendering.
     *
     * @rendering String | The view rendering.
     */
    private function applyWiringToOuterElement( required rendering ){
        var renderingResult = "";

        // Provide a hash of our rendering which is used by Livewire JS.
        var renderingHash = hash( arguments.rendering );

        // Determine our outer element.
        var outerElement = variables.getOuterElement( arguments.rendering );

        // Add properties to top element to make cbwire actually work.
        if ( variables.$isInitialRendering ){
            // Initial rendering
            renderingResult = rendering.replaceNoCase(
                outerElement,
                outerElement & " wire:id=""#this.getID()#"" wire:initial-data=""#serializeJSON( this.getInitialData( renderingHash = renderingHash ) ).replace( """", "&quot;", "all" )#""",
                "once"
            );
        } else{
            // Subsequent renderings
            renderingResult = rendering.replaceNoCase(
                outerElement,
                outerElement & " wire:id=""#this.getID()#""",
                "once"
            );
        }

        return renderingResult;
    }

    /**
     * Determines the outer element within our rendering.
     * If an outer element isn't found, an error is thrown.
     *
     * @rendering String | The view rendering.
     */
    private function getOuterElement( required rendering ){
        var matches = reMatchNoCase( "<[a-z]+\s*", arguments.rendering );

        if ( arrayLen( matches ) ){
            return matches[ 1 ];
        }

        throw( type = "OuterElementNotFound", message = "Unable to find an outer element to bind cbwire to." );
    }

    /**
     * Returns our HTTP referer.
     *
     * @return String
     */
    private function getHTTPReferer(){
        return cgi.HTTP_REFERER;
    }

}
