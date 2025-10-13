<cfoutput>
<!-- CBWIRE SCRIPTS -->
<script src="#moduleSettings.moduleRootURL#/includes/js/livewire/dist/livewire.js?id=v3.6.4" <cfif not moduleSettings.navigateShowProgressBar>data-no-progress-bar</cfif> data-csrf="#generateCSRFToken()#" data-update-uri="#getUpdateEndpoint()#" data-navigate-once="true"></script>

<script data-navigate-once="true">
    document.addEventListener('livewire:init', () => {
        window.cbwire = window.Livewire;
        // Refire but as cbwire:init
        document.dispatchEvent( new CustomEvent( 'cbwire:init' ) );
    } );

    document.addEventListener('livewire:initialized', () => {
        // Refire but as cbwire:initialized
        document.dispatchEvent( new CustomEvent( 'cbwire:initialized' ) );
    } );

    document.addEventListener('livewire:navigated', () => { 
        // Refire but as cbwire:navigated
        document.dispatchEvent( new CustomEvent( 'cbwire:navigated' ) );
    } );
</script>
</cfoutput>
