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
        local.cfmPath = getCFMPath( arguments.componentPath );

        if ( fileExists( local.cfmPath ) ) {
            local.files = generateFiles( arguments.componentName, local.cfmPath );
            return loadComponent( arguments.componentName, listLast( local.files.tempComponentName, "." ), arguments.module );
        }
    }

    /**
     * Returns the .CFM path.
     *
     * @return string
     */
    private function getCFMPath( required componentPath ){
        local.cfmPath = replaceNoCase( arguments.componentPath, ".", "/", "all" );
        return expandPath( "/" & local.cfmPath & ".cfm" );
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
     * Generates the CFC and CFM files for single-file components.
     *
     * @return void
     */
    private function generateFiles( componentName, sourceCFMPath ){
        local.parsedContents = parseContents( arguments.sourceCFMPath );
        arguments.componentName = listLast( arguments.componentName, "." );

        local.currentDirectory = getDirectoryFromPath( getCurrentTemplatePath() );
        local.tmpDirectory = local.currentDirectory & "tmp";
        local.tmpCFCPath = local.tmpDirectory & "/#arguments.componentName#.cfc";
        local.tmpCFMPath = local.tmpDirectory & "/#arguments.componentName#.cfm";

        if ( fileExists( local.tmpCFMPath ) && fileExists( local.tmpCFMPath ) ) {
            // Compare the timestamp of the source file and the temp file
            // If the source file is less than the temp file, then we don't need to re-generate
            local.sourceFile = getFileInfo( arguments.sourceCFMPath );
            local.tempFile = getFileInfo( local.tmpCFMPath );

            if ( local.sourceFile.lastModified < local.tempFile.lastModified ) {
                return { "tempComponentName" : "#arguments.componentName#" };
            }
        }

        if ( !directoryExists( local.tmpDirectory ) ) {
            directoryCreate( local.tmpDirectory );
        }

        local.emptySingleFileComponent = fileRead( local.currentDirectory & "EmptySingleFileComponent.cfc" );

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

        fileWrite( local.tmpCFCPath, local.emptySingleFileComponent );
        fileWrite( local.tmpCFMPath, local.parsedContents.remainingContents );

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