component accessors="true" singleton {

    property name="wirebox" inject="wirebox";
    property name="settings" inject="coldbox:modulesettings:cbwire";
    property name="initialRender" default="true";

    /**
     * Builds an single-file component if it can locate the necessary files.
     * Otherwise, returns null.
     *
     * @return Component
     */
    function build( required componentPath, required componentName, module = "" ){
        lock name="buildComponent-#hash(arguments.componentPath)#" timeout="5" {
            local.singleFilePath = getSingleFilePath( arguments.componentPath );
            local.files = generateFiles( arguments.componentName, local.singleFilePath );
            return loadComponent( arguments.componentName, listLast( local.files.tempComponentName, "." ), arguments.module );
        }
    }

    /**
     * Returns the .CFM path.
     *
     * @return string
     */
    private function getSingleFilePath( required componentPath ){
        local.relativeBasePath = replaceNoCase( arguments.componentPath, ".", "/", "all" );
        local.fullBoxlangPath = expandPath( "/" & local.relativeBasePath & ".bxm" );
        local.fullCFMLPath = expandPath( "/" & local.relativeBasePath & ".cfm" );

        if ( fileExists( local.fullBoxlangPath ) ) {
            return local.fullBoxlangPath;
        } else if ( fileExists( local.fullCFMLPath ) ) {
            return local.fullCFMLPath;
        } else {
            throw( type="CBWIREException", message="The CBWIRE component '#arguments.componentPath#' does not exist. Please ensure the file exists and is named correctly." );
        }
    }

    /**
     * Parse the contents of our .CFM page
     *
     * @return struct
     */
    function parseContents( required cfmPath ){
        local.fileContents = fileRead( arguments.cfmPath );
        local.singleFileContents = "";
        local.remainingContents = "";
        local.extendsPath = "cbwire.models.Component";

        local.startedWire = false;
        local.endedWire = false;

		local.isBoxLang = arguments.cfmPath.listToArray(".").last() == "bxm" ? true : false;
		local.insideScriptTag = false;
		local.REStartScriptTag = local.isBoxLang ? "<\s*bx:script\s*>" : "<\s*cfscript\s*>";
		local.REEndScriptTag = local.isBoxLang ? "<\s*/\s*bx:script\s*>" : "<\s*/\s*cfscript\s*>";

        for ( local.line in local.fileContents.listToArray( chr( 10 ) ) ) {

			if ( REFindNoCase( local.REStartScriptTag, local.line ) > 0 ) {
				local.insideScriptTag = true;
			}
			if ( REFindNoCase( local.REEndScriptTag, local.line  ) > 0 ) {
				local.insideScriptTag = false;
			}

            // Parse @extends annotation
            if ( local.insideScriptTag && local.line contains "@extends" ) {
                local.extendsMatch = reFindNoCase( "@extends\s*\(\s*['""]?([^'""\)\s]+)['""]?\s*\)", local.line, 1, true );
                if ( arrayLen( local.extendsMatch.match ) >= 2 && len( local.extendsMatch.match[ 2 ] ) ) {
                    local.capturedPath = local.extendsMatch.match[ 2 ];
                    // Validate that the path contains only valid characters (alphanumeric, dots, underscores)
                    if ( reFindNoCase( "^[a-zA-Z0-9_\.]+$", local.capturedPath ) ) {
                        local.extendsPath = local.capturedPath;
                    }
                }
                continue;
            }

            if ( local.insideScriptTag && local.line contains "@startWire" ) {
                local.startedWire = true;
                continue;
            }
			if ( local.insideScriptTag && local.line contains "@endWire" ) {
                local.endedWire = true;
                continue;
            }

            if ( local.startedWire && !local.endedWire ) {
                local.singleFileContents &= local.line & chr( 10 );
            } else {
                local.remainingContents &= local.line & chr( 10 );
            }
        }

        return {
            "singleFileContents" : local.singleFileContents,
            "remainingContents" : local.remainingContents,
            "extendsPath" : local.extendsPath
        };
    }

    /**
     * Generates the Boxlang for CFML files for single-file components.
     *
     * @return void
     */
    private function generateFiles( componentName, sourcePath ){

		local.isBoxLang = arguments.sourcePath.listToArray(".").last() == "bxm" ? true : false;

        local.parsedContents = parseContents( arguments.sourcePath );

        arguments.componentName = replaceNoCase( arguments.componentName, "wires.", "" );

        arguments.componentName = replace( arguments.componentName, ".", "/", "all" );

        local.currentDirectory = getDirectoryFromPath( getCurrentTemplatePath() );
        local.tmpDirectory = local.currentDirectory & "tmp";

        if ( local.isBoxLang ) {
            local.tmpClassPath = local.tmpDirectory & "/#arguments.componentName#.bx";
            local.tmpTemplatePath = local.tmpDirectory & "/#arguments.componentName#.bxm";
        } else {
            local.tmpClassPath = local.tmpDirectory & "/#arguments.componentName#.cfc";
            local.tmpTemplatePath = local.tmpDirectory & "/#arguments.componentName#.cfm";
        }

        if ( fileExists( local.tmpClassPath ) && fileExists( local.tmpTemplatePath ) ) {
            // Compare the timestamp of the source file and the temp file
            // If the source file is less than the temp file, then we don't need to re-generate
            local.sourceFile = getFileInfo( arguments.sourcePath );
            local.tempFile = getFileInfo( local.tmpTemplatePath );

            if ( local.sourceFile.lastModified < local.tempFile.lastModified ) {
                return { "tempComponentName" : "#arguments.componentName#" };
            }
        }

        if ( !directoryExists( local.tmpDirectory ) ) {
            directoryCreate( local.tmpDirectory );
        }

        // Recursively create all subdirectories for the component path in tmp storage
        local.componentDirectory = getDirectoryFromPath( local.tmpClassPath );
        ensureDirectoryExists( local.componentDirectory );

        if ( local.isBoxLang ) {
            local.emptySingleFileComponent = fileRead( local.currentDirectory & "EmptySingleFileComponent.bx" );
        } else {
            local.emptySingleFileComponent = fileRead( local.currentDirectory & "EmptySingleFileComponent.cfc" );
        }

        local.emptySingleFileComponent = replaceNoCase(
            local.emptySingleFileComponent,
            "{{ CFC_CONTENTS }}",
            local.parsedContents.singleFileContents,
            "one"
        );

        local.emptySingleFileComponent = replaceNoCase(
            local.emptySingleFileComponent,
            "{{ TEMPLATE_PATH }}",
            "cbwire.models.tmp.#arguments.componentName#",
            "one"
        );

        local.emptySingleFileComponent = replaceNoCase(
            local.emptySingleFileComponent,
            "{{ EXTENDS_PATH }}",
            local.parsedContents.extendsPath,
            "one"
        );

        local.uuid = createUUID();

        fileWrite( local.tmpClassPath, local.emptySingleFileComponent );
        fileWrite( local.tmpTemplatePath, local.parsedContents.remainingContents );

        return { "tempComponentName" : "#arguments.componentName#" };
    }

    /**
     * Returns a single-file stub component.
     *
     * @componentName string
     * @module string
     *
     * @return Component
     */
    private function loadComponent( required componentName, required tempComponentName, module = "" ){
        local.comp = getWireBox().getInstance( "cbwire.models.tmp.#arguments.tempComponentName#" );
        return local.comp;
    }

    /**
     * Recursively creates directories if they don't exist.
     * Compatible with ACF which doesn't support the createPath argument.
     *
     * @directoryPath string
     *
     * @return void
     */
    private function ensureDirectoryExists( required directoryPath ){
        if ( directoryExists( arguments.directoryPath ) ) {
            return;
        }

        local.parentDirectory = getDirectoryFromPath( arguments.directoryPath.reReplace( "[\\/]$", "" ) );

        if ( len( local.parentDirectory ) && local.parentDirectory != arguments.directoryPath ) {
            ensureDirectoryExists( local.parentDirectory );
        }

        if ( !directoryExists( arguments.directoryPath ) ) {
            directoryCreate( arguments.directoryPath );
        }
    }

}