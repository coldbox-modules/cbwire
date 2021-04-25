/**
 * Represents an subsequent, incoming Livewire XHR Request from the browser.
 */
component singleton{
    
    /**
     * Injected ColdBox controller which we will use to access our app and module settings
     */
    property name="controller" inject="coldbox";

    /**
     * Injected WireBox because DI rocks.
     */
    property name="wirebox" inject="wirebox";

    /**
     * Injected RequestService so that we can access the current ColdBox RequestContext.
     */
    property name="requestService" inject="coldbox:requestService";

    /**
     * Returns the current ColdBox RequestContext event.
     *
     * @return RequestContext
     */
    function getEvent() {
        return variables.requestService.getContext();
    }

    /**
     * Returns true if our request context contains a 'fingerprint' property.
     * 
     * @return boolean
     */
    function hasFingerprint() {
        return structKeyExists( this.getCollection(), "fingerprint" );
    }  

    /**
     * Returns true if our request context contains a 'serverMemo' property.
     * 
     * @return boolean
     */
    function hasServerMemo() {
        return structKeyExists( this.getCollection(), "serverMemo" );
    }

    /**
     * Returns the serverMemo from our request context.
     * 
     * @return struct
     */
    function getServerMemo() {
        return this.getCollection()[ "serverMemo" ];
    }

    /**
     * Returns true if our request context contains an 'updates' property.
     * 
     * @return boolean
     */
    function hasUpdates() {
        return structKeyExists( this.getCollection(), "updates" );
    }

    /**
     * Returns an array of LivewireUpdate objects with our updates from the request context.
     * 
     * @return array | LivewireUpdate
     */
    function getUpdates() {
        return this.getCollection()[ "updates" ].map( function( update ) {
            return variables.wirebox.getInstance( name="cbLivewire.models.LivewireUpdate", initArguments={ update: arguments.update } );
        } );
    }

    function getCollection() {
        return getEvent().getCollection( argumentCollection=arguments );
    }

    function withComponent( componentName ) {
        if ( reFindNoCase( "handlers\.cbLivewire\.", arguments.componentName ) ) {
            arguments.componentName = reReplaceNoCase( arguments.componentName, "handlers\.cbLivewire\.", "", "one" );
        }

        if( find( "@", arguments.componentName ) ){
            return getModuleComponent( arguments.componentName );
        } else {
            return getRootComponent( arguments.componentName );
        }
    }

	function renderIt( componentName ){
		return withComponent( arguments.componentName )
            .$mount()
            .renderIt();
	}

    // Root convention: helloWorld
    private function getRootComponent( required string componentName ) {
        var appMapping = variables.controller.getSetting( "AppMapping" );
        var livewireRoot = ( len( appMapping ) ? appMapping & "." : "" ) & "handlers.cbLivewire";
        return variables.wirebox.getInstance( "#livewireRoot#.#arguments.componentName#");
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