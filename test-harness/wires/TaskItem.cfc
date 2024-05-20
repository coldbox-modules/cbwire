component extends="cbwire.models.Component" {

    data = {
        "task": ""
    };

    function deleteTask( task ) {
        dispatch( "deleteTask", { task: task } );
    }
}