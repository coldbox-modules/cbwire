component accessors="true" singleton {

	property name="wirebox" inject="wirebox";

	property name="initialRender" default="true";

	/**
	 * Builds an inline component if it can locate the necessary files.
	 * Otherwise, returns null.
	 *
	 * @return Component
	 */
	function build( required componentPath, required componentName, module = "" ){
		var cfmPath = getCFMPath( arguments.componentPath );

		if ( fileExists( cfmPath ) ) {
			var files = generateFiles( arguments.componentName, parseContents( cfmPath ) );

			return loadComponent( arguments.componentName, listLast( files.tempComponentName, "." ), arguments.module );
		}
	}

	/**
	 * Returns the .CFM path.
	 *
	 * @return string
	 */
	private function getCFMPath( required componentPath ){
		var cfmPath = replaceNoCase( arguments.componentPath, ".", "/", "all" );
		return expandPath( "/" & cfmPath & ".cfm" );
	}

	/**
	 * Parse the contents of our .CFM page
	 *
	 * @return struct
	 */
	function parseContents( required cfmPath ){
		var fileContents = fileRead( cfmPath );
		var inlineContents = "";
		var remainingContents = "";

		var startedWire = false;
		var endedWire = false;

		for ( var line in fileContents.listToArray( chr( 10 ) ) ) {
			if ( line contains "<cfscript>" ) {
				startedWire = true;
				continue;
			}
			if ( line contains "</cfscript>" ) {
				endedWire = true;
				continue;
			}

			if ( startedWire && !endedWire ) {
				inlineContents &= line & chr( 10 );
			} else {
				remainingContents &= line;
			}
		}

		return {
			"inlineContents" : inlineContents,
			"remainingContents" : remainingContents
		};
	}

	/**
	 * Generates the CFC and CFM files for inline component.
	 *
	 * @return void
	 */
	private function generateFiles( componentName, parsedContents ){
		arguments.componentName = listLast( arguments.componentName, "." );

		var currentDirectory = getDirectoryFromPath( getCurrentTemplatePath() );
		var tmpDirectory = currentDirectory & "tmp";
		var tmpCFCPath = tmpDirectory & "/#arguments.componentName#.cfc";
		var tmpCFMPath = tmpDirectory & "/#arguments.componentName#.cfm";
		
		if ( fileExists( tmpCFCPath ) && fileExists( tmpCFMPath ) ) {
			return { "tempComponentName" : "#arguments.componentName#" };
		}

		if ( !directoryExists( tmpDirectory ) ) {
			directoryCreate( tmpDirectory );
		}

		var emptyInlineComponent = fileRead( currentDirectory & "EmptyInlineComponent.cfc" );

		emptyInlineComponent = replaceNoCase(
			emptyInlineComponent,
			"// Inline Contents Goes Here",
			arguments.parsedContents.inlineContents,
			"one"
		);

		var uuid = createUUID();

		fileWrite( tmpCFCPath, emptyInlineComponent );
		fileWrite( tmpCFMPath, arguments.parsedContents.remainingContents );

		return { "tempComponentName" : "#arguments.componentName#" };
	}

	/**
	 * Returns a inline stub component.
	 *
	 * @componentName string
	 * @module string
	 *
	 * @return Component
	 */
	private function loadComponent( required componentName, required tempComponentName, module = "" ){
		var comp = getWireBox().getInstance( "cbwire.models.tmp.#arguments.tempComponentName#" );

		comp.setInlineComponentType( arguments.componentName );
		comp.setInlineComponentId( arguments.tempComponentName );
		comp.setModule( arguments.module );

		return comp;
	}

}
