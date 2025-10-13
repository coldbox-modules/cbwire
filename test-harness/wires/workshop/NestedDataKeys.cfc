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
			"roles" : [ "editor" ]
		},
		"showSuccess": false
    };

	function submit() {
		data.showSuccess = true;
    }


}