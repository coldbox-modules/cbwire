<cfoutput>
<div wire:init="loadTasks">
    <ul>
        <cfloop array="#args.tasks#" index="task">
            <li>#task#</li>
        </cfloop>
    </ul>
</div>
</cfoutput>