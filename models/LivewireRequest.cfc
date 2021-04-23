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
        return getCollection()[ "serverMemo" ];
    }

    function hasUpdates() {
        return structKeyExists( getCollection(), "updates" );
    }

    function getUpdates() {
        return getCollection()[ "updates" ].map( function( update ) {
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

		return wirebox.getInstance(
			name          = "handlers.cbLivewire.#componentName#",
			initArguments = { livewireRequest : this }
		);
    }

	function renderIt( componentName ){
		return withComponent( componentName )
            .$mount()
            .renderIt();
	}

}