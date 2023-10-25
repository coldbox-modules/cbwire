component accessors="true" singleton {

	property name="populator" inject="wirebox:populator";

	function handle( comp, event, rc, prc ){
		if ( structKeyExists( comp.getParent(), "mount" ) ) {
			comp.getParent()
				.mount(
					parameters = arguments.parameters, // deprecated
					params = arguments.parameters,
					key = arguments.key,
					event = event,
					rc = rc,
					prc = prc
				);
		} else if ( structKeyExists( comp.getParent(), "onMount" ) ) {
			comp.getParent()
				.onMount(
					parameters = arguments.parameters, // deprecated
					params = arguments.parameters,
					key = arguments.key,
					event = event,
					rc = rc,
					prc = prc
				);
		} else {
			/**
			 * Use scope population to populate our component.
			 */

			// check datatypes parameters and throw error if not string, boolean, numeric, date, array, or struct
			for( var paramKey IN arguments.parameters.keyArray() ){
				if( !isSimpleValue( arguments.parameters[ paramKey ] ) 
					&& !isArray( arguments.parameters[ paramKey ] ) 
					&& !isStruct( arguments.parameters[ paramKey ] )
				){
					throw( 
						type 		= "MissingOnMount", 
						message 	= "The wire does NOT have onMount() function and the paramaters passed contain a 
									  data type other than a string, boolean, numeric, date, array, or struct and cannot 
									  be automatically inserted into the data properties. To avoid this error create an 
									  onMount() method to handle incoming paramaters" 
					);
				}
			}

			// if parameters passed in are string, boolean, numeric, date, array, or struct insert into variables.data
			getPopulator().populateFromStruct(
				target: comp.getParent(),
				memento: arguments.parameters,
				scope: "variables.data"
			);
		}

		// Capture the state before hydration
		comp.setBeforeHydrationState( duplicate( comp.getState() ) );
	}

}
