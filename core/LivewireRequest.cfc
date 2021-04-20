component accessors="true" singleton{

    property name="controller" inject="coldbox";
    property name="wirebox" inject="wirebox";
    property name="requestService" inject="coldbox:requestService";
    property name="modulesConfig" inject="coldbox:modulesConfig";

  

    function getEvent() {
        return requestService.getContext();
    }

    function hasFingerprint() {
        return structKeyExists( getCollection(), "fingerprint" );
    }  

    function hasServerMemo() {
        return structKeyExists( getCollection(), "serverMemo" );
    }

    function getServerMemo() {
        return getCollection()[ "serverMemo" ];
    }

    function hasUpdates() {
        return structKeyExists( getCollection(), "updates" );
    }

    function getUpdates() {
        return getCollection()[ "updates" ].map( function( update ) {
            return wirebox.getInstance( name="cbLivewire.core.LivewireUpdate", initArguments={ update: update } );
        } );
    }

    function getCollection() {
        return getEvent().getCollection( argumentCollection=arguments );
    }

    function withComponent( componentName ) {
        if ( reFindNoCase( "handlers\.cbLivewire\.", componentName ) ) {
            arguments.componentName = reReplaceNoCase( componentName, "handlers\.cbLivewire\.", "", "one" );
        }

		return wirebox.getInstance(
			name          = "handlers.cbLivewire.#componentName#",
			initArguments = { livewireRequest : this }
		);

        if( find( "@", arguments.componentName ) ){
            return getModuleComponent()
        } else {
            return getRootComponent()
        }

        // Root convention: helloWorld
        var appMapping = variables.controller.getSetting( "AppMapping" );
        var livewireRoot = ( len( appMapping ) ? appMapping & "." : "" ) & "livewire";
        wirebox.getInstance( "#livewireRoot#.#componentName#")

        // ModuleConvention: helloWorld@ui

        // Verify the module
        variables.modulesConfig.keyExists( moduleName ); //else throw exception
        // Instantion Prefix of the module
        var livewireModuleRoot = variables.modulesConfig[ moduleName ].invocationPath & ".livewire"


    }

	function render( componentName ){
		return withComponent( componentName )
            .$mount()
            .render();
	}

}