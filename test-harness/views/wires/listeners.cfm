<cfsavecontent variable="prc.viewJavascript">
    <!-- 
        We can listen to events in Javascript.
        See layouts/Main.cfm where we include prc.viewJavascript. We use
        cfsavecontent here to store our page JS in a variable that
        is later included at the bottom of the app's layout
        where 'cbwire' exists.
    -->
    <script>
        cbwire.on( 'sentMessage', function() {
            alert( 'Annoying pop-up' );
        } );
    </script>
</cfsavecontent>

<cfoutput>
    <div>
        <form wire:submit.prevent="sendMessage">
            <input wire:model="message" type="text">
            <button type="submit">Send Message</button>
        </form>
        <cfif args.sent>
            <div class="mt-4 alert alert-info">
                Message sent
            </div>
        </cfif>
    </div>
</cfoutput>