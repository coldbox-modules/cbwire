<cfoutput>
    <div>
        <h1>Task List</h1>

        <form wire:submit="addTask">
            <input wire:model="newTask" class="form-control" type="text" placeholder="Enter a new task">
            <button class="mt-3 btn btn-primary" type="submit">Add Task</button>
        </form>

        <hr>

        <cfif not tasks().len()>
            <p>No tasks found.</p>
        <cfelse>
            <cfloop array="#tasks()#" index="task">
                <div wire:key="#hash(task)#">
                    #wire( name="TaskItem", params={ task: task }, key=hash(task) )#
                </div>
            </cfloop>
        </cfif>
    </div>
</cfoutput>