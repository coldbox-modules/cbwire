<cfoutput>
    <div>
        <form wire:submit.prevent="sendMessage">
            <input wire:model="message" type="text">
            <button type="submit" class="btn btn-primary">Send Message</button>
        </form>
    </div>
</cfoutput>