component extends="cbwire.models.Component"{

    data = {
        "calculation": 0
    };

    computed = {
        "onePlusTwo": function() {
            return 1 + 2;
        }
    }

    function doSomething(){
        data.calculation = this.getOnePlusTwo();
    }
}