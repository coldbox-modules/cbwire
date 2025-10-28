component extends="cbwire.models.Component" {

	data = {
		"keyOne": "valueOne",
		"keyTwo": "valueTwo"
	};

	function updateDataKeyOne() {
		data.keyOne = "updatedValueOne";
	}

	function updateDataKeyTwo() secured {
		data.keyTwo = "updatedValueTwo";
	}

}