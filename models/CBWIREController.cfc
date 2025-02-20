component singleton {

    // Injected WireBox instance so that we can dynamically create instances of components.
    property name="wirebox" inject="wirebox";

    // Injected RequestService so that we can access the current ColdBox RequestContext.
    property name="requestService" inject="coldbox:requestService";

    // Inject CBCSRF for CSRF token generation and verification
    property name="cbcsrf" inject="provider:@cbcsrf";

    // Inject module settings
    property name="moduleSettings" inject="coldbox:modulesettings:cbwire";
    
    // Inject module service
    property name="moduleService" inject="coldbox:moduleService";

    // Inject SingleFileComponentBuilder
    property name="singleFileComponentBuilder" inject="SingleFileComponentBuilder@cbwire";

    function init() {
        // Initialize the array to store single file components
        variables._singleFileComponents = [];
        return this;
    }
    /**
     * Instantiates a CBWIRE component, mounts it,
     * and then calls its onRender() method.
     *
     * @name The name of the component to load.
     * @params The parameters you want mounted initially. Defaults to an empty struct.
     * @key An optional key parameter. Defaults to an empty string.
     * @lazy Whether the component should be lazy loaded or not. Defaults to false.
     * @lazyIsolated Whether the component should be lazy loaded in an isolated manner. Defaults to true.
     *
     * @return An instance of the specified component after rendering.
     */
    function wire(required name, params = {}, key = "", lazy = false, lazyIsolated = true ) {
        local.instance = createInstance(argumentCollection=arguments)
                ._withPath( arguments.name )
                ._withEvent( getEvent() )
                ._withParams( arguments.params, arguments.lazy )
                ._withKey( arguments.key );

        // If the component is lazy loaded, we need to generate an x-intersect snapshot of the component
        return arguments.lazy ? 
            local.instance._generateXIntersectLazyLoadSnapshot( params=arguments.params ) : 
            local.instance._render();
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
        // Track state for entire request
        local.httpRequestState = {
            "assets": {}
        };
        // Perform initial deserialization of the incoming request payload
        local.payload = deserializeJSON( arguments.incomingRequest.content );
        // Set the CSRF token for the request
        local.csrfToken = local.payload._token;
        // Validate the CSRF token
        local.csrfTokenVerified = variables.wirebox.getInstance( dsl="@cbcsrf" ).verify( local.csrfToken );
        // Check the CSRF token, throw 403 if invalid
        if( !local.csrfTokenVerified ){
            throw( type="CBWIREException", message="Page expired." );
        }
        // Perform additional deserialization of the component snapshots
        local.payload.components = local.payload.components.map( function( _comp ) {
            arguments._comp.snapshot = deserializeJSON( arguments._comp.snapshot );
            return arguments._comp;
        } );
        // Iterate over each component in the payload and process it
        local.componentsResult = {
            "components": local.payload.components.map( ( _componentPayload ) => {
                // Locate the component and instantiate it.
                local.componentInstance = createInstance( _componentPayload.snapshot.memo.name );
                // Return the response for this component
                return local.componentInstance
                            ._withPath( _componentPayload.snapshot.memo.name )
                            ._withEvent( event )
                            ._withIncomingPayload( _componentPayload )
                            ._getHTTPResponse( _componentPayload, httpRequestState );
            } )
        };

        // Return assets from components
        if ( local.httpRequestState.assets.count() ) {
            var alreadyLoadedAssets = payload.components.reduce( function( _agg, _comp ) {
                if ( _comp.snapshot.memo.keyExists( "assets" ) ) {
                    _comp.snapshot.memo.assets.each( function( _asset ) {
                        _agg.append( _asset );
                    } );
                }
                return _agg;
            }, [] );

            local.componentsResult[ "assets" ] = local.httpRequestState.assets.filter( function( key, value ) {
                return !arrayFindNoCase( alreadyLoadedAssets, key );
            } );

            if ( !local.componentsResult[ "assets" ].count() ) {
                local.componentsResult[ "assets" ] = [];
            }
        }

        // Set the response headers to prevent caching
        event.setHTTPHeader( name="Pragma", value="no-cache" );
        event.setHTTPHeader( name="Expires", value="Fri, 01 Jan 1990 00:00:00 GMT" );
        event.setHTTPHeader( name="Cache-Control", value="no-cache, must-revalidate, no-store, max-age=0, private" );

        return local.componentsResult;
    }

    /**
     * Uploads all files from the request to the specified destination
     * after verifying the signed URL.
     * 
     * @incomingRequest The JSON struct payload of the incoming request.
     * @event The event object.
     * 
     * @return A struct representing the response with updated component details or an error message.
     */
    function handleFileUpload( incomingRequest, event ) {
        // Determine our storage path for temporary files
        local.storagePath = getCanonicalPath( variables.moduleSettings.moduleRootPath & "/models/tmp" );

        // Ensure the storage path exists
        if( !directoryExists( local.storagePath ) ){
            directoryCreate( local.storagePath );
        }
        // Cleanup files in the storage path by checking for files older than 1 days
        local.files = directoryList( path=local.storagePath, recurse=true, type="file", listInfo="query" );
        local.files.each( function( _file ) {
            if( dateDiff( "d", _file.DateLastModified, now() ) > 1 ){
                fileDelete( _file );
            }
        } );
        // Verify the signed URL, throw 403 if invalid
        if( !verifySignedUploadURL( expires=event.getValue( "expires" ), signature=event.getValue( "signature" ) ) ){
            return event.renderData( statusCode=403, statusText="Forbidden", data="Invalid signed URL." );
        }
        // Perform actual upload of files
        local.results = fileUploadAll( destination=local.storagePath, onConflict="makeUnique" );
        local.paths = local.results.map( function( _result ) {
            local.id = createUUID();
            fileWrite( getCanonicalPath( storagePath & "/#local.id#.json" ), serializeJSON( arguments._result ) );
            return id;
        } );
        return { "paths": local.paths };
    }

    /**
     * Handles the preview of a file by reading the file metadata and sending it back to the client.
     * 
     * @incomingRequest The JSON struct payload of the incoming request.
     * @event The event object.
     * 
     * @return file contents
     */
    function handleFilePreview( incomingRequest, event ){
        local.uuid = event.getValue( "uploadUUID", "" );
        if ( !len( local.uuid ) ) {
            return event.noRender();
        }

        local.metaPath = getCanonicalPath( variables.moduleSettings.moduleRootPath & "models/tmp/#local.uuid#.json" );

        local.metaJSON = deserializeJSON( fileRead( local.metaPath ) );
        local.contents = fileReadBinary( getCanonicalPath( variables.moduleSettings.moduleRootPath & "models/tmp/#local.metaJSON.serverFile#" ) );
        event
            .sendFile(
                file = local.contents,
                disposition = "inline",
                extension = local.metaJSON.serverFileExt,
                mimeType = "#local.metaJSON.contentType#/#local.metaJSON.contentSubType#"
            )
            .noRender();
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
        local.fullComponentPath = arguments.name;
        
        if ( !local.fullComponentPath contains "wires." ) {
            local.fullComponentPath = "wires." & local.fullComponentPath;
        }
        
        if ( find( "@", local.fullComponentPath ) ) {
            // This is a module reference, find in our module
            var params = listToArray( local.fullComponentPath, "@" );
            if ( params.len() != 2 ) {
                throw( type="ModuleNotFound", message = "CBWIRE cannot locate the module or component using '" & local.fullComponentPath & "'." );
            }
            // modify local.fullComponentPath to full path for module
            local.fullComponentPath = getModuleComponentPath( params[ 1 ], params[ 2 ] );
        }

        try {
            // Check if we've already flagged this component as a single file component
            // This is to improve performance by not attempting to create the component again
            if ( variables._singleFileComponents.contains( arguments.name ) ) {
                throw( type="Injector.InstanceNotFoundException", message="Component '#arguments.name#' is a single file component." );
            }
            // Attempt to create an instance of the component
            local.componentInstance = variables.wirebox.getInstance(local.fullComponentPath)
                ._withPath( arguments.name );
            return local.componentInstance;
        } catch( Injector.InstanceNotFoundException e ) {
            local.singleFileComponent = variables.singleFileComponentBuilder
                .setInitialRender( true )
                .build( fullComponentPath, arguments.name, getCurrentRequestModule() );
            if ( isNull( local.singleFileComponent ) ) {
                writeDump( local );
                abort;
                rethrow;
            }
            variables._singleFileComponents.append( arguments.name );

            return local.singleFileComponent;
        } catch (Any e) {
            writeDump( e );
            abort;
            // Log error or handle it as needed
            throw("ApplicationException", "Unable to instantiate component '#arguments.name#'. Detail: #e.message#");
        }
    }

    /** 
    * Returns the path to the modules folder.
    * 
    * @module string | The name of the module.
    *
    * @return string
    */
    function getModuleRootPath( module ) {
        var moduleRegistry = moduleService.getModuleRegistry();

        if ( moduleRegistry.keyExists( module ) ) {
            return moduleRegistry[ module ].invocationPath & "." & module;
        }

        throw( type="ModuleNotFound", message = "CBWIRE cannot locate the module '" & arguments.module & "'.")
    }

    /**
     * Returns the full dot notation path to a modules component.
     *
     * @path String | Name of the cbwire component.
     * @module String | Name of the module to look for wire in.
     */
    function getModuleComponentPath( path, module ) {
        var moduleConfig = moduleService.getModuleConfigCache();
        if ( !moduleConfig.keyExists( module ) ) {
            throw( type="ModuleNotFound", message = "CBWIRE cannot locate the module '" & arguments.module & "'.")
        }

        // if there is a dot in the path, then we are referencing a folder within a module otherwise use the default wire location.
        var moduleRegistry = moduleService.getModuleRegistry();

        var result = arguments.path contains "." ?
            moduleRegistry[ module ].invocationPath & "." & module & "." & arguments.path :
            moduleRegistry[ module ].invocationPath & "." & module & "." & getWiresLocation() & "." & arguments.path;

        return result;
    }

    /**
     * Returns the path to the wires folder within a module path.
     *
     * @module string | The name of the module.
     * 
     * @return string 
     */
    function getModuleWiresPath( module ) {
        local.moduleRegistry = moduleService.getModuleRegistry();
        return arguments
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
     * Returns any request assets defined by components during the request.
     * 
     * @return struct
     */
    function getRequestAssets() {
        local.event = getEvent();
        local.event.paramPrivateValue( "cbwireRequestAssets", {} );
        return local.event.getPrivateValue( "cbwireRequestAssets" );
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
        // List of preprocesssors here. Had to hard code instead of using 
        // directoryList because of filesystem differences in various OSes
        local.files = [
            "TemplatePreprocessor.cfc",
            "CBWIREPreprocessor.cfc",
            "TeleportPreprocessor.cfc"
        ];
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
    function getStyles( cache=true ) {
        if (structKeyExists(variables, "styles") && arguments.cache ) {
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
     * We don't cache the results like we do with
     * styles because we need to generate a unique
     * CSRF token for each request.
     * 
     * @return string
     */
    function getScripts() {       
        savecontent variable="local.html" {
            include "scripts.cfm";
        }
        return local.html;
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

    /**
     * Generates a secure signature for the upload URL.
     * 
     * @baseURL string | The base URL for the upload request.
     * @expires string | The expiration time for the request.
     * 
     * @return string
     */
    function generateSignature(baseUrl, expires) {
        // Get secret key from CBCSRF
        local.secretKey = generateCSRFToken();
        // Example of generating a HMAC SHA-256 signature
        local.stringToSign = arguments.baseUrl & arguments.expires;
        // Using HMAC with SHA-256 to generate the signature
        return hash(local.stringToSign & local.secretKey, "SHA-256");
    }

    /**
     * Generates a CSRF token for the current request.
     * 
     * @return string
     */
    function generateCSRFToken() {
        // Generate the CSRF token using the cbcsrf library
        return variables.cbcsrf.generate();
    }

    /**
     * Returns the base URL for incoming requests.
     * 
     * @return string
     */
    function getBaseURL() {
        local.requestURL = CGI.HTTP_REFERER;
        local.regexMatches = reFindNoCase( "https*://[^/]+", local.requestURL, 1, true );
        return local.regexMatches.match[1];
    }

    /**
     * Generates a signed upload URL.
     *
     * @return string
     */
    function generateSignedUploadURL() {
        // Get our base URL
        local.baseURL = getBaseURL();
        // Set the expiration time to 1 hour from now and convert it to a Unix timestamp
        local.expires = dateConvert( "local2Utc", now() );
        local.expires = dateDiff( "s", createDate( 1970, 1, 1 ), local.expires ) + 3600; // Adding 3600 seconds (1 hour)
        // Generate a secure signature. You'll need to define the `generateSignature` method
        local.signature = generateSignature( local.baseURL, local.expires );
        // Construct the upload URL with the query parameters
        return local.baseURL & "/cbwire/upload?expires=" & local.expires & "&signature=" & urlEncodedFormat( local.signature );
    }

    /**
     * Verifies signed upload URL.
     * 
     * @return boolean
     */
    function verifySignedUploadURL( expires, signature ) {
        // Get our base URL
        local.baseURL = getBaseURL();
        // Generate a secure signature. You'll need to define the `generateSignature` method
        local.generatedSignature = generateSignature( local.baseURL, arguments.expires );
        // Compare the generated signature with the one from the URL
        return arguments.signature == local.generatedSignature;
    }

    /**
     * Returns the module of the current request.
     *
     * @return string
     */
    function getCurrentRequestModule(){
        local.rc = requestService.getContext().getCollection();
        return structKeyExists( local.rc, "fingerprint" ) ? local.rc.fingerprint.module : variables.requestService.getContext().getCurrentModule();
    }

    /**
     * Pass-through method to the view method of the renderer.
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
        return requestService.getController().getRenderer().view( argumentCollection=arguments );
    }

    /**
     * Returns the URI endpoint for updating CBWIRE components.
     * 
     * @return string
     */
    function getUpdateEndpoint() {
        var settings = variables.moduleSettings;        
        return settings.keyExists( "updateEndpoint") && settings.updateEndpoint.len() ? settings.updateEndpoint : "/cbwire/update";
    }
}