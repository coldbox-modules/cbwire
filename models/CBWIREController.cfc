component singleton {

    // Injected WireBox instance so that we can dynamically create instances of components.
    property name="wirebox" inject="wirebox";

    // Injected RequestService so that we can access the current ColdBox RequestContext.
    property name="requestService" inject="coldbox:requestService";

    /**
     * Instantiates a CBWIRE component, mounts it,
     * and then calls its internal renderIt() method.
     *
     * @name The name of the component to load.
     * @params The parameters you want mounted initially. Defaults to an empty struct.
     * @key An optional key parameter. Defaults to an empty string.
     * @lazy Whether the component should be lazy loaded or not. Defaults to false.
     *
     * @return An instance of the specified component after rendering.
     */
    function wire(required name, params = {}, key = "", lazy = false ) {
        local.instance = createInstance(argumentCollection=arguments)
                ._withEvent( getEvent() )
                ._withParams( arguments.params, arguments.lazy )
                ._withKey( arguments.key );

        // If the component is lazy loaded, we need to generate an x-intersect snapshot of the component
        return arguments.lazy ? 
            local.instance._generateXIntersectLazyLoadSnapshot( params=arguments.params ) : 
            local.instance.renderIt();
    }

    /**
     * Handles incoming AJAX requests to update or interact with CBWIRE components.
     *
     * @incomingRequest The JSON struct payload of the incoming request.
     * @event The event object.
     * 
     * @return A struct representing the response with updated component details or an error message.
     */
    function handleRequest( incomingRequest, event ) {
        // Perform initial deserialization of the incoming request payload
        var payload = deserializeJSON( arguments.incomingRequest.content );
        // Perform additional deserialization of the component snapshots
        payload.components = payload.components.map( function( comp ) {
            comp.snapshot = deserializeJSON( comp.snapshot );
            return comp;
        } );
        // Iterate over each component in the payload and process it
        local.componentsResult = {
            "components": payload.components.map( ( _componentPayload ) => {
                // Locate the component and instantiate it.
                var componentInstance = createInstance( _componentPayload.snapshot.memo.name );
                // Return the response for this component
                return componentInstance
                            ._withEvent( event )
                            ._withIncomingPayload( _componentPayload )
                            ._getHTTPResponse( _componentPayload );
            } )
        };

        // Set the response headers to prevent caching
        event.setHTTPHeader( name="Pragma", value="no-cache" );
        event.setHTTPHeader( name="Expires", value="Fri, 01 Jan 1990 00:00:00 GMT" );
        event.setHTTPHeader( name="Cache-Control", value="no-cache, must-revalidate, no-store, max-age=0, private" );

        return local.componentsResult;
    }

    /**
     * Dynamically creates an instance of a CBWIRE component based on the provided name.
     * Assumes components are located within a specific namespace or directory structure.
     *
     * @componentName The name of the component to instantiate, possibly including a namespace.
     * @params Optional parameters to pass to the component constructor.
     * @key Optional key to use when retrieving the component from WireBox.
     * 
     * @return The instantiated component object.
     * @throws ApplicationException If the component cannot be found or instantiated.
     */
    function createInstance( name ) {
        // Determine if the component name traverses a valid namespace or directory structure
        var fullComponentPath = arguments.name;
        
        if (!fullComponentPath contains "wires.") {
            fullComponentPath = "wires." & fullComponentPath;
        }
        
        try {
            // Attempt to create an instance of the component
            return variables.wirebox.getInstance(fullComponentPath);
        } catch (Any e) {
            writeDump( e );
            abort;
            // Log error or handle it as needed
            throw("ApplicationException", "Unable to instantiate component '#arguments.name#'. Detail: #e.message#");
        }
    }

    /**
     * Returns the ColdBox RequestContext object.
     * 
     * @return The ColdBox RequestContext object.
     */
    function getEvent(){
        return variables.requestService.getContext();
    }

    /**
     * Returns the ColdBox ConfigSettings object.
     * 
     * @return struct
     */
    function getConfigSettings(){
        return variables.wirebox.getInstance( dsl="coldbox:configSettings" );
    }

    /**
     * Returns an array of preprocessor instances.
     * 
     * @return An array of preprocessor instances.
     */
    function getPreprocessors(){
        // Check if we've already scanned the folder
        if( structKeyExists( variables, "preprocessors" ) ){
            return variables.preprocessors;
        }
        // Scan the folder 'preprocessor' for all CFCs and return an array
        local.files = directoryList( 
            path=getDirectoryFromPath(getCurrentTemplatePath()) & "preprocessor",
            recurse=false,
            listInfo="name",
            filter="*.cfc",
            type="file"
        );
        // Map the files to their getInstance path
        variables.preprocessors = local.files.map( ( _file ) => {
            local.getInstancePath = replace( _file, ".cfc", "" ) & "@cbwire";
            return wirebox.getInstance( dsl=getInstancePath );
        } );

        return variables.preprocessors;
    }

    /**
     * Returns CSS styling needed by Livewire.
     * 
     * @return string
     */
    function getStyles() {
        if (structKeyExists(variables, "styles")) {
            return variables.styles;
        }
        
        savecontent variable="local.html" {
            include "styles.cfm";
        }
        
        variables.styles = local.html;
        return variables.styles;
    }

    /**
     * Returns JavaScript needed by Livewire.
     * 
     * @return string
     */
    function getScripts() {
        if (structKeyExists(variables, "scripts")) {
            return variables.scripts;
        }
        
        savecontent variable="local.html" {
            include "scripts.cfm";
        }
        
        variables.scripts = local.html;
        return variables.scripts;
    }

    /**
     * Returns HTML to persist the state of anything inside the call.
     * 
     * @return string
     */
    function persist( name ) {
        return "<div x-persist=""player"">";
    }

    /**
     * Ends the persistence of the state of anything inside the call.
     * 
     * @return string
     */
    function endPersist() {
        return "</div>";
    }

}