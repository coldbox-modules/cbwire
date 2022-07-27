<cfoutput>
    <div wire:poll>
        Current timestamp: <span class="fw-bold">#dateTimeFormat( args.timestamp, "full")#</span>
    </div>
</cfoutput>