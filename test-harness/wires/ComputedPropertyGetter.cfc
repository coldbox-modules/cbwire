component extends="cbwire.models.Component"{

    variables.data = {
        "calculation": 0
    };

    variables.computed = {
        "onePlusTwo": function() {
            return 1 + 2;
        }
    }

    function doSomething(){
        variables.data.calculation = this.getOnePlusTwo();
    }
}