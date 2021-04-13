/**
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
*/
component {

	// APPLICATION CFC PROPERTIES
	this.name               = "ColdBoxTestingSuite" & hash( getCurrentTemplatePath() );
	this.sessionManagement  = true;
	this.sessionTimeout     = createTimespan( 0, 0, 15, 0 );
	this.applicationTimeout = createTimespan( 0, 0, 15, 0 );
	this.setClientCookies   = true;

	// Create testing mapping
	this.mappings[ "/tests" ] = getDirectoryFromPath( getCurrentTemplatePath() );

	// The application root
	rootPath = reReplaceNoCase(
		this.mappings[ "/tests" ],
		"tests(\\|/)",
		""
	);
	this.mappings[ "/root" ] = rootPath;

	// UPDATE THE NAME OF THE MODULE IN TESTING BELOW
	request.MODULE_NAME = "cbLivewire";

	// The module root path
	moduleRootPath = reReplaceNoCase(
		this.mappings[ "/root" ],
		"#request.module_name#(\\|/)test-harness(\\|/)",
		""
	);
	this.mappings[ "/moduleroot" ]            = moduleRootPath;
	this.mappings[ "/#request.MODULE_NAME#" ] = moduleRootPath & "#request.MODULE_NAME#";

	// request start
	public boolean function onRequestStart( String targetPage ){
		if ( url.keyExists( "fwreinit" ) ) {
			if ( structKeyExists( server, "lucee" ) ) {
				pagePoolClear();
			}
		}

		return true;
	}

	public function onRequestEnd(){
		// CB 6 graceful shutdown
		if ( !isNull( application.cbController ) ) {
			application.cbController.getLoaderService().processShutdown();
		}

		structDelete( application, "cbController" );
		structDelete( application, "wirebox" );
	}

}
