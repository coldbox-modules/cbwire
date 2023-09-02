<cfsavecontent variable="prc.viewJavascript">
    <!-- 
        We can listen to events in Javascript.
        See layouts/Main.cfm where we include prc.viewJavascript. We use
        cfsavecontent here to store our page JS in a variable that
        is later included at the bottom of the app's layout
        where 'cbwire' exists.
    -->
    <script>
        cbwire.on( 'success', function( payload ) {
            alert( 'Message sent at' );
        } );
    </script>
</cfsavecontent>

<cfoutput>
    <div>
        <form wire:submit.prevent="sendMessage">
            <input wire:model="message" type="text">
            <button type="submit" class="btn btn-primary">Send Message</button>
        </form>
    </div>
</cfoutput>