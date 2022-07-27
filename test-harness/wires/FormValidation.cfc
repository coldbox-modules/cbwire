component extends="cbwire.models.Component" {

    this.constraints = {
        "task": { required: true, type: "email" }
    };

    data = {
        "task": ""
    };

    function addTask() {
        validateOrFail();
        data.task = "whatever";
    }
}