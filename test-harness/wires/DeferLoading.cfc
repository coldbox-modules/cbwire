
// ./wires/TaskList.cfc
component extends="cbwire.models.Component" {
    
    data = {
        "tasks": []
    };
    
    function loadTasks(){
        data.tasks = data.tasks.append( "yep" );
    }
    

}