component singleton{
    
    property name="controller" inject="coldbox";
    property name="wirebox" inject="wirebox";
    property name="requestService" inject="coldbox:requestService";

    function getEvent() {
        return requestService.getContext();
    }

    function hasFingerprint() {
        return structKeyExists( this.getCollection(), "fingerprint" );
    }  

    function hasServerMemo() {
        return structKeyExists( this.getCollection(), "serverMemo" );
    }

    function getServerMemo() {
        return this.getCollection()[ "serverMemo" ];
    }

    function hasUpdates() {
        return structKeyExists( this.getCollection(), "updates" );
    }

    function getUpdates() {
        return this.getCollection()[ "updates" ].map( function( update ) {
            return wirebox.getInstance( name="cbLivewire.models.LivewireUpdate", initArguments={ update: update } );
        } );
    }

    function getCollection() {
        return getEvent().getCollection( argumentCollection=arguments );
    }

    function withComponent( componentName ) {
        if ( reFindNoCase( "handlers\.cbLivewire\.", componentName ) ) {
            arguments.componentName = reReplaceNoCase( componentName, "handlers\.cbLivewire\.", "", "one" );
        }

        if( find( "@", arguments.componentName ) ){
            return getModuleComponent( arguments.componentName );
        } else {
            return getRootComponent( arguments.componentName );
        }
    }

	function renderIt( componentName ){
		return withComponent( componentName )
            .$mount()
            .renderIt();
	}

    // Root convention: helloWorld
    private function getRootComponent( required string componentName ) {
        var appMapping = variables.controller.getSetting( "AppMapping" );
        var livewireRoot = ( len( appMapping ) ? appMapping & "." : "" ) & "handlers.cbLivewire";
        return wirebox.getInstance( "#livewireRoot#.#arguments.componentName#");
    }

    // ModuleConvention: helloWorld@ui
    private function getModuleComponent( required string componentName ) {
        throw(message="Need to finish implementing this");
        // Verify the module
        variables.modulesConfig.keyExists( moduleName ); //else throw exception
        // Instantion Prefix of the module
        var livewireModuleRoot = variables.modulesConfig[ moduleName ].invocationPath & ".livewire"
    }

}