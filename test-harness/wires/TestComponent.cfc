component extends="cbwire.models.Component" {

    data = [
        "title": "CBWIRE Rocks!",
        "mailinglist": "x-men at marvel.com",
        "heroes": [],
        "villians": [],
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

    function defeatVillians(){
        data.villians = [];
    }

    function addHero(hero){
        data.heroes.append(hero);
    }

    function addVillian(villian){
        data.villians.append(villian);
    }

    function numberOfHeroes() computed {
        return data.heroes.len();
    }

    function numberOfVillians() computed {
        return data.villians.len();
    }

    function calculateStrength() computed {
        return getTickCount();
    }

}