<cfoutput>
<div>
    <input wire:model="task" type="text">
    <button wire:click="addTask">Add Task</button>

    <cfif args.validation.hasErrors( "task" )>
        <cfloop array="#args.validation.getAllErrors( "task" )#" index="error">
            <div>#error#</div>
        </cfloop>
    </cfif>
</div>
</cfoutput>