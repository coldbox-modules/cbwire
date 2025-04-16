component singleton {

    function init() {
        variables.tasks = [];
        // You can initialize any data or perform setup here
    }

    function addTask( task ) {
        variables.tasks.append( arguments.task );
        // This function adds a new task to the tasks array
    }

    function deleteTask( task ) {
        variables.tasks.delete( arguments.task );
        // This function removes a task from the tasks array
    }

    function getTasks() {
        // Simulates a delay, like fetching data from a database
        sleep( 3000 );
        // Returns the current list of tasks
        return variables.tasks;
    }

}