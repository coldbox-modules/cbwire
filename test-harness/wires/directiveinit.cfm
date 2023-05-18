<cfoutput>
    <div wire:init="loadMessages">
        <div wire:loading>
            Pulling down messages...
        </div>
        <cfloop array="#args.messages#" index="messageObj">
            <div>#messageObj.message#</div>
        </cfloop>
    </div>
</cfoutput>