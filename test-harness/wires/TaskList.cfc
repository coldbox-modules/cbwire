component extends="cbwire.models.Component" {

    data = {
        "newTask": "",
        "tasks": []
    };

    function addTask() {
        data.tasks.append( data.newTask );
        reset( "newTask" );
    }

    function onRender() {
        return template( "wires.TaskList" );
    }

}