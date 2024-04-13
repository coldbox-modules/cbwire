component {

    property name="wirebox" inject="wirebox";

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
        return wirebox.getInstance("CBWIREController@cbwire")
                .createInstance(argumentCollection=arguments)
                ._withParams( arguments.params )
                ._withKey( arguments.key )
                ._withHTTPRequestData( getHTTPRequestData() )
                .renderIt();
    }

    /**
     * Handles incoming AJAX requests to update or interact with CBWIRE components.
     *
     * @param payload The JSON string payload of the incoming request.
     * @return A JSON string representing the response with updated component details or an error message.
     */
    public string function handleRequest(required string payload) {
        // Implementation of AJAX request handling
        var data = deserializeJson(arguments.payload);
        var responseComponents = [];
        var isValidRequest = true;

        // Example logic for processing a request
        data.components.each(function(componentData) {
            var componentInstance = createInstance(componentData.memo.name); // This method needs to be defined or adjusted according to your logic for instantiation
            // Further processing...
        });

        if (!isValidRequest) {
            return serializeJson({ "error": "Invalid request detected." });
        }

        return serializeJson({ "components": responseComponents });
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
    public any function createInstance(required string name ) {
        // Determine if the component name traverses a valid namespace or directory structure
        var fullComponentPath = arguments.name;
        
        if (!fullComponentPath contains "wires.") {
            fullComponentPath = "wires." & fullComponentPath;
        }
        
        try {
            // Attempt to create an instance of the component
            return wirebox.getInstance(fullComponentPath);
        } catch (Any e) {
            writeDump( e );
            abort;
            // Log error or handle it as needed
            throw("ApplicationException", "Unable to instantiate component '#arguments.name#'. Detail: #e.message#");
        }
    }

}