component singleton {

    function init() {
        variables.tasks = [];
    }

    function addTask( task ) {
        variables.tasks.append( arguments.task );
    }

    function deleteTask( task ) {
        variables.tasks.delete( arguments.task );
    }

    function getTasks() {
        sleep( 3000 );
        return variables.tasks;
    }

}