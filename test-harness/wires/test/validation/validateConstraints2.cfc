component extends="cbwire.models.Component" {

    data = {
        "firstname": "sdfsad",
        "lastname": ""
    }
	/*
		This components DOES use constraints=

		The cbwire documentation states that you can define constraints using constraints=
		https://cbwire.ortusbooks.com/features/form-validation

		CBValidation documentation states that you define constraints using this.constraints=
		https://coldbox-validation.ortusbooks.com/overview/declaring-constraints/domain-object
	*/
    constraints = {
        "firstname": { required: true }
    };

}