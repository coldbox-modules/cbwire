component extends="cbwire.models.Component" {
    data = {
        "user": {
			"name": {
				"first": "John",
				"last": "Doe"
			},
			"email": "jdoe@ortus.local",
			"address": {
				"street": "123 Main St",
				"city": "Severn",
				"state": "MD",
				"zip": "12345"
			},
			"roles" : [ "editor" ],
			"subscriptions" : {
				"newsletter" : true,
				"alerts" : false
			}
		},
		"showSuccess": false
    };

	function resetDataAll() {
        reset(); // Reverts all data to initial state
    }

	function resetDataKey( key ){
		// accepts nested keys like 'user.address.street'
		reset( key );
	}

	function resetExceptDataKey( key ){
		// accepts nested keys like 'user.address.street'
		resetExcept( key );
	}

	function setDataToNonDefaultValues() {
		data.user.name.first = createUUID().left(10);
		data.user.name.last = createUUID().left(12);
		data.user.email = createUUID().left(8) & "@ortus.local";
		data.user.address.street = createUUID().left(5) & " Main St";
		data.user.address.city = createUUID().left(10);
		data.user.address.state = "VA";
		data.user.address.zip = randRange(10000,99999);
		data.user.subscriptions.newsletter = false;
		data.user.subscriptions.alerts = true;
		data.user.roles = [ "admin", "auditor" ];
	}

	function submit() {
		data.showSuccess = true;
    }

}