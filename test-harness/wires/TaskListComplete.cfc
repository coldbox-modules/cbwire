component extends="cbwire.models.Component" {

    property name="TaskService" inject="TaskService";
    
    data = {
        "newTask": ""
    };

    listeners = {
        "deleteTask": "deleteTask"
    };

    function placeholder() {
        return "<div>Loading task list...</div>";
    }

    function tasks() {
        return taskService.getTasks();
    }

    function addTask() {
        taskService.addTask( data.newTask );
        reset( "newTask" );
    }

    function deleteTask( task ){
        taskService.deleteTask( arguments.task );
    }

    function renderIt() {
        return view( "wires.TaskListComplete" );
    }

}