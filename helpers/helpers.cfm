<cfscript>  
    /**
    * Returns the styles to be placed in HTML head
    */
    function livewireStyles() {
        return getInstance( "cbLivewire.core.LivewireHTML" ).getStyles();
    }

    /**
    * Returns the JS to be placed in HTML body
    */
    function livewireScripts() {
        return getInstance( "cbLivewire.core.LivewireHTML" ).getScripts();
    }

    /**
    * Renders a livewire component
    */
    function livewire( componentName ) {
        return getInstance( name="cbLivewire.core.LivewireRequest", initArguments={ event: event }).render( componentName );
        //return getInstance( "cbLivewire.core.CBLivewire" ).render( variables.event, componentName );
    }
</cfscript>
