component  accessors="true" {

	property name="FirstName";
	property name="LastName";

	this.constraints = {
	    FirstName : {
			required : true,
			requiredMessage : "First name is required",
			size : "2..50",
			sizeMessage : "First name must be 2-50 characters"
		},
		LastName : {
			required : true,
			requiredMessage : "Last name is required",
			size : "2..50",
			sizeMessage : "Last name must be 2-50 characters"
		}
	};

}