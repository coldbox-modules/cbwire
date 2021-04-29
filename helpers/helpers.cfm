<cfscript>  
    /**
    * Returns the styles to be placed in HTML head
    */
    function livewireStyles() {
        return getInstance( "cbLivewire.models.LivewireHTML" ).getStyles();
    }

    /**
    * Returns the JS to be placed in HTML body
    */
    function livewireScripts() {
        return getInstance( "cbLivewire.models.LivewireHTML" ).getScripts();
    }

    /**
    * Renders a livewire component
    */
    function livewire() {
        return getInstance( "cbLivewire.models.LivewireRequest" ).renderIt( argumentCollection=arguments );
    }
</cfscript>
