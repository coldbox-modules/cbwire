component extends="cbwire.models.Component" secured {

	data = {
		"keyOne"	: "valueOne",
		"keyTwo"	: "valueTwo",
		"keyThree"	: "valueThree",
		"keyFour"	: "valueFour"
	};

	function updateDataKeyOne() secured="read" {
		data.keyOne = "updatedValueOne";
	}

	function updateDataKeyTwo() secured="write" {
		data.keyTwo = "updatedValueTwo";
	}

	function updateDataKeyThree() secured="read, write" {
		data.keyThree = "updatedValueThree";
	}

	function updateDataKeyFour() secured="noSuchPermission" {
		data.keyFour = "updatedValueFour";
	}


}
