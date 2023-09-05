component accessors="true" singleton {

	// Inject ColdBox, needed by FrameworkSuperType
	property name="controller" inject="coldbox";

    function handle( comp ) {
        // Determine the type of relocation
		var relocationType = "SES";
		var relocationURL = "";
		var eventName = getController().getConfigSettings()[ "EventName" ];
		var frontController = listLast( CGI.SCRIPT_NAME, "/" );
		var oRequestContext = getController().getRequestService().getContext();
		var routeString = 0;

		// Determine relocation type
		if ( !isNull( arguments.url ) && len( arguments.url ) ) {
			relocationType = "URL";
		}
		if ( !isNull( arguments.URI ) && len( arguments.URI ) ) {
			relocationType = "URI";
		}

		// Cleanup event string to default if not sent in
		if ( len( trim( arguments.event ) ) eq 0 ) {
			arguments.event = getController().getSetting( "DefaultEvent" );
		}

		// Query String Struct to String
		if ( isStruct( arguments.queryString ) ) {
			arguments.queryString = arguments.queryString
				.reduce( function( result, key, value ){
					arguments.result.append( "#encodeForURL( arguments.key )#=#encodeForURL( arguments.value )#" );
					return arguments.result;
				}, [] )
				.toList( "&" );
		}

		// Overriding Front Controller via baseURL argument
		if ( len( trim( arguments.baseURL ) ) ) {
			frontController = arguments.baseURL;
		}

		// Relocation Types
		switch ( relocationType ) {
			// FULL URL relocations
			case "URL": {
				relocationURL = arguments.URL;
				// Check SSL?
				if ( !isNull( arguments.ssl ) ) {
					relocationURL = getController().updateSSL( relocationURL, arguments.ssl );
				}
				// Query String?
				if ( len( trim( arguments.queryString ) ) ) {
					relocationURL = relocationURL & "?#arguments.queryString#";
				}
				break;
			}

			// URI relative relocations
			case "URI": {
				relocationURL = arguments.URI;
				// Query String?
				if ( len( trim( arguments.queryString ) ) ) {
					relocationURL = relocationURL & "?#arguments.queryString#";
				}
				break;
			}

			// Default event relocations
			default: {
				// Convert module into proper entry point
				if ( listLen( arguments.event, ":" ) > 1 ) {
					var mConfig = getController().getSetting( "modules" );
					var module = listFirst( arguments.event, ":" );
					if ( structKeyExists( mConfig, module ) ) {
						arguments.event = mConfig[ module ].inheritedEntryPoint & "/" & listRest( arguments.event, ":" );
					}
				}
				// Route String start by converting event syntax to / syntax
				routeString = replace( arguments.event, ".", "/", "all" );
				// Convert Query String to convention name value-pairs
				if ( len( trim( arguments.queryString ) ) ) {
					// If the routestring ends with '/' we do not want to
					// double append '/'
					if ( right( routeString, 1 ) NEQ "/" ) {
						routeString = routeString & "/" & replace( arguments.queryString, "&", "/", "all" );
					} else {
						routeString = routeString & replace( arguments.queryString, "&", "/", "all" );
					}
					routeString = replace( routeString, "=", "/", "all" );
				}

				// Get Base relocation URL from context
				relocationURL = oRequestContext.getSESBaseURL();
				// if the sesBaseURL is nothing, set it to the setting
				if ( !len( relocationURL ) ) {
					relocationURL = getController().getSetting( "sesBaseURL" );
				}
				// add the trailing slash if there isnt one
				if ( right( relocationURL, 1 ) neq "/" ) {
					relocationURL = relocationURL & "/";
				}
				// Check SSL?
				if ( !isNull( arguments.ssl ) ) {
					relocationURL = getController().updateSSL( relocationURL, arguments.ssl );
				}

				// Finalize the URL
				relocationURL = relocationURL & routeString;

				break;
			}
		}
		// persist Flash RAM
		persistVariables( argumentCollection = arguments );

		// Post Processors
		if ( NOT arguments.postProcessExempt ) {
			getController().getInterceptorService().announce( "postProcess" );
		}

		// Save Flash RAM
		if ( getController().getConfigSettings().flash.autoSave ) {
			controller
				.getRequestService()
				.getFlashScope()
				.saveFlash();
		}

		comp.setRedirectTo( relocationURL );
    }

    /**
	 * Internal helper to flash persist elements
	 *
	 * @persist       What request collection keys to persist in flash RAM automatically for you
	 * @persistStruct A structure of key-value pairs to persist in flash RAM automatically for you
	 *
	 * @return Controller
	 */
	private function persistVariables( persist = "", struct persistStruct = {} ){
		var flash = getController().getRequestService().getFlashScope();

		// persist persistStruct if passed
		if ( !isNull( arguments.persistStruct ) ) {
			flash.putAll( map = arguments.persistStruct, saveNow = true );
		}

		// Persist RC keys if passed.
		if ( len( trim( arguments.persist ) ) ) {
			flash.persistRC( include = arguments.persist, saveNow = true );
		}

		return this;
	}
}