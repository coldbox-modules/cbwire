component extends="cbwire.models.Component" {

	data = {
		"keyOne"	: "valueOne"
	};

	function onSecure( event, prc, isInitial, params ) {
		return false;
	}

	function updateDataKeyOne() {
		data.keyOne = "updatedValueOne";
	}

}