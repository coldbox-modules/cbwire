component accessors="true" {
    
    property name="wirebox" inject="wirebox";
    property name="requestService" inject="coldbox:requestService";

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
        return getCollection().serverMemo;
    }

    function hasUpdates() {
        return structKeyExists( getCollection(), "updates" );
    }

    function getUpdates() {
        return getCollection()[ "updates" ];
    }

    function getCollection() {
        return getEvent().getCollection( argumentsCollection=arguments );
    }

    function withComponent( componentName ) {
        if ( reFindNoCase( "handlers\.cbLivewire\.", componentName ) ) {
            arguments.componentName = reReplaceNoCase( componentName, "handlers\.cbLivewire\.", "", "one" );
        }

		return wirebox.getInstance(
			name          = "handlers.cbLivewire.#componentName#",
			initArguments = { livewireRequest : this }
		);
    }

	function render( componentName ){
		return withComponent( componentName ).render();
	}

}