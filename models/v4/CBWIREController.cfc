component singleton {

    property name="wirebox" inject="wirebox";

	// Injected RequestService so that we can access the current ColdBox RequestContext.
	property name="requestService" inject="coldbox:requestService";

    /**
     * Instantiates a CBWIRE component, mounts it,
     * and then calls its internal renderIt() method.
     *
     * @param name The name of the component to load.
     * @param params The parameters you want mounted initially. Defaults to an empty struct.
     * @param key An optional key parameter. Defaults to an empty string.
     *
     * @return An instance of the specified component after rendering.
     */
    function wire(required string name, struct params = {}, string key = "") {
        return createInstance(argumentCollection=arguments)
                ._withEvent( getEvent() )
                ._withParams( arguments.params )
                ._withKey( arguments.key )
                .renderIt();
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
     * @param componentName The name of the component to instantiate, possibly including a namespace.
     * @param params Optional parameters to pass to the component constructor.
     * @param key Optional key to use when retrieving the component from WireBox.
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

}