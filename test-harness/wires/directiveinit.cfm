<cfoutput>
    <div wire:init="loadMessages">
        <div wire:loading>
            Pulling down messages...
        </div>
        <cfif messages.len()>
            <div wire:transition.duration.3000ms>
                <cfloop array="#messages#" index="messageObj">
                    <div>#messageObj.message#</div>
                </cfloop>
            </div>
        </cfif>
    </div>
</cfoutput>