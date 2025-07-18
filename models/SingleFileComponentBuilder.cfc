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

        local.startedWire = false;
        local.endedWire = false;

        for ( local.line in local.fileContents.listToArray( chr( 10 ) ) ) {
            if ( local.line contains "@startWire" ) {
                local.startedWire = true;
                continue;
            }
            if ( local.line contains "@endWire" ) {
                local.endedWire = true;
                continue;
            }

            if ( local.startedWire && !local.endedWire ) {
                local.singleFileContents &= local.line & chr( 10 );
            } else {
                local.remainingContents &= local.line & chr( 10 );
            }
        }

        if ( !local.startedWire || !local.endedWire ) {
            throw( type="CBWIREException", message="The CBWIRE component '#arguments.cfmPath#' is missing '//@startWire' and '//@endWire' markers. Please place these in your CFSCRIPT block and place each one on a single line." );
        }

        return {
            "singleFileContents" : local.singleFileContents,
            "remainingContents" : local.remainingContents
        };
    }

    /**
     * Generates the Boxlang for CFML files for single-file components.
     *
     * @return void
     */
    private function generateFiles( componentName, sourcePath ){
        local.parsedContents = parseContents( arguments.sourcePath );

        arguments.componentName = listLast( arguments.componentName, "." );

        local.currentDirectory = getDirectoryFromPath( getCurrentTemplatePath() );
        local.tmpDirectory = local.currentDirectory & "tmp";

        if ( arguments.sourcePath contains ".bxm" ) {
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

        if ( arguments.sourcePath contains ".bxm" ) {
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

        // local.comp.setSingleFileComponentType( arguments.componentName );
        // local.comp.setSingleFileComponentId( arguments.tempComponentName );
        // local.comp.setModule( arguments.module );

        return local.comp;
    }

}