component extends="cbwire.models.v4.Component" {

    data = {
        "heroes": [],
        "villians": [],
        "isMarvel": true,
        "isDC": false
    };

    function defeatVillians(){
        villians = [];
    }

    function addHero(hero){
        heroes.append(hero);
    }

    function addVillian(villian){
        villians.append(villian);
    }

    function numberOfHeroes() computed {
        return heroes.len();
    }

    function numberOfVillians() computed {
        return villians.len();
    }

    function calculateStrength() computed {
        return getTickCount();
    }
}