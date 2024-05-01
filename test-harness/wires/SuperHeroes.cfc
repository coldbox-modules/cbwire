component extends="cbwire.models.Component" {

    data = {
        "mailinglist": "x-men at marvel.com",
        "heroes": [],
        "villians": [],
        "isMarvel": true,
        "isDC": false,
        "showStats": false
    };

    constraints = {
        "mailingList": { required: true, type: "email" }
    };

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