component {

    function preReinit() {

	    var settings = getInstance( "coldbox:modulesettings:cbwire" );

        var tmpDirectory = settings.moduleRootPath & "/models/tmp";

        if ( directoryExists( tmpDirectory ) ) {
            directoryDelete( tmpDirectory, true );
            directoryCreate( tmpDirectory );
        }
    }
}