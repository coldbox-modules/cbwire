component extends="cbwire.models.Component" {

    data = [
        "title": "CBWIRE Rocks!",
        "mailinglist": "x-men at marvel.com",
        "modules": [],
        "frameworks": [],
        "isMarvel": true,
        "isDC": false,
        "showStats": false
    ];

    listeners = [
        "someEvent": "someListener"
    ];

    constraints = [
        "mailingList": { required: true, type: "email" }
    ];

    function runJSMethod(){
        js( "alert('Hello from CBWIRE!');" );
        js( "console.log('Hello from CBWIRE!');" );
    }

    function runActionWithReturnValue() {
        return "Return from CBWIRE!";
    }

    function runStream() {
        stream( "target", "someValue", true );
    }

    function changeTitle() {
        data.title = "CBWIRE Slays!";
    }

    function resetTitle() {
        reset( "title" );
    }

    function resetAll() {
        reset();
    }

    function someListener() {
        data.title = "Fired some event";
    }

    function performRedirect() {
        relocate( event="main.index" );
    }

    function placeholder() {
        return "Test Placeholder";
    }

    function clearFrameworks(){
        data.frameworks = [];
    }

    function addModule(module){
        data.modules.append(module);
    }

    function addFramework(framework){
        data.frameworks.append(framework);
    }

    function numberOfModules() computed {
        return data.modules.len();
    }

    function numberOfFrameworks() computed {
        return data.frameworks.len();
    }

    function calculateStrength() computed {
        return getTickCount();
    }

}