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
        return getInstance( "cbLivewire.core.LivewireRequest" ).render( componentName );
    }
</cfscript>
