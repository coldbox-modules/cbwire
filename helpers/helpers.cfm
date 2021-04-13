<cfscript>  
    /**
    * Returns the styles to be placed in HTML head
    */
    function livewireStyles() {
        return getInstance( "cblivewire.core.CBLivewire" ).getStyles();
    }

    /**
    * Returns the JS to be placed in HTML body
    */
    function livewireScripts() {
        return getInstance( "cblivewire.core.CBLivewire" ).getScripts();
    }

    /**
    * Renders a livewire component
    */
    function livewire( componentName ) {
        return getInstance( "cblivewire.core.CBLivewire" ).render( variables.event, componentName );
    }
</cfscript>
