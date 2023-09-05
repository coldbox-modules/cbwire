component accessors="true" singleton {

    function handle( comp, methodName, methodArguments={} ) {
		var settings = comp.getSettings();

		var data = comp.getDataProperties();

		var computed = comp.getComputedProperties();

        if ( reFindNoCase( "^get.+", arguments.methodName ) ) {
			// Extract data property name from the getter method called.
			var propertyName = reReplaceNoCase( arguments.methodName, "^get", "", "one" )

			// Check to see if the data property name is defined on the component.
			if ( structKeyExists( data, propertyName ) ) {
				return data[ propertyName ];
			}

			// Check to see if the computed property name is defined in the component.
			if ( structKeyExists( computed, propertyName ) ) {
				return computed[ propertyName ];
			}
		}

		if ( reFindNoCase( "^set.+", arguments.methodName ) ) {
			// Extract data property name from the setter method called.
			var dataPropertyName = reReplaceNoCase( arguments.methodName, "^set", "", "one" );

			// Check to see if the data property name is defined in the component.
			var dataPropertyExists = structKeyExists( data, dataPropertyName );

			if ( dataPropertyExists ) {
				// Handle variations in methodArguments from wirebox bean populator and our own implemented setters.
				if ( structKeyExists( arguments.methodArguments, "value" ) ) {
					comp.setProperty( dataPropertyName, arguments.methodArguments.value );
				} else {
					comp.setProperty( dataPropertyName, arguments.methodArguments[ 1 ], true );
				}
			} else if (
				structKeyExists( settings, "throwOnMissingSetterMethod" ) && settings.throwOnMissingSetterMethod == true
			) {
				throw( type = "WireSetterNotFound", message = "The wire property '#dataPropertyName#' was not found." );
			}
		}
    }
}