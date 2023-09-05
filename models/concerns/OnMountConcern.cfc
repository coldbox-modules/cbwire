component accessors="true" singleton {

	property name="populator" inject="wirebox:populator";

    function handle( comp, event, rc, prc ) {
        if ( structKeyExists( comp.getParent(), "mount" ) ) {
			comp.getParent().mount(
				parameters = arguments.parameters,
				key = arguments.key,
				event = event,
				rc = rc,
				prc = prc
			);
		} else if ( structKeyExists( comp.getParent(), "onMount" ) ) {
			comp.getParent().onMount(
				parameters = arguments.parameters,
				key = arguments.key,
				event = event,
				rc = rc,
				prc = prc
			);
		} else {
			/**
			 * Use setter population to populate our component.
			 */
			getPopulator().populateFromStruct(
				target: this,
				trustedSetter: true,
				memento: arguments.parameters,
				excludes: ""
			);
		}

		// Capture the state before hydration
		comp.setBeforeHydrationState( duplicate( comp.getState() ) );
    }
}