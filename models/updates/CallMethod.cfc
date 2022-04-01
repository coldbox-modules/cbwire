component extends="WireUpdate" {

	/**
	 * Runs the specified action method within the request payload on the provided component.
	 *
	 * @return Void
	 */
	function apply( required comp ){
		// Handle $set calls.
		if ( variables.getPayloadMethod() == "$set" ) {
			invoke(
				arguments.comp,
				"set" & variables.getPassedParamsAsArguments()[ 1 ],
				[ variables.getPassedParamsAsArguments()[ 2 ] ]
			);
			return;
		} else if ( variables.getPayloadMethod() == "$refresh" ) {
			invoke( arguments.comp, "refresh", variables.getPassedParamsAsArguments() );
			return;
		} else if ( variables.getPayloadMethod() == "startUpload" ) {
			arguments.comp.getEngine().startUpload( variables.getPassedParamsAsArguments() );
			return;
		} else if ( variables.getPayloadMethod() == "finishUpload" ) {
			arguments.comp.getEngine().finishUpload();
		} else {
			// Handle action calls.
			if ( variables.hasCallableAction( arguments.comp ) ) {
				try {
					invoke( arguments.comp, variables.getPayloadMethod(), variables.getPassedParamsAsArguments() );
				} catch ( ValidationException validateException ) {
					// Silently stop further action processing on validationOrFail() exceptions.
				}
				return;
			}

			// We cannot locate the action, so throw an error.
			throw(
				type = "WireActionNotFound",
				message = "Wire action '" & variables.getPayloadMethod() & "' not found on your component."
			);
		}
	}

	/**
	 * Returns true if the provided cbwire component has a callable method that matches
	 * the specific method in the update.
	 *
	 * @comp cbwire.models.Component | The cbwire component we are checking the callable method on.
	 *
	 * @return Boolean
	 */
	private function hasCallableAction( required comp ){
		return variables.hasPayloadMethod() && arguments.comp.getEngine().hasMethod( variables.getPayloadMethod() );
	}

	/**
	 * Returns the passed parameters as a key value struct instead of an array.
	 *
	 * @return Struct
	 */
	private function getPassedParamsAsArguments(){
		if ( variables.hasPassedParams() ) {
			return variables
				.getPassedParams()
				.reduce( function( agg, param, index ){
					arguments.agg[ index ] = param;
					return arguments.agg;
				}, {} );
		}
		return {};
	}

	/**
	 * Returns the parameters included with the incoming payload.
	 *
	 * @return Array
	 */
	private function getPassedParams(){
		return this.getPayload()[ "params" ];
	}

	/**
	 * Returns true if the update payload includes an array of parameters.
	 *
	 * @return Boolean
	 */
	private function hasPassedParams(){
		return this.hasPayload() && structKeyExists( this.getPayload(), "params" ) && isArray(
			this.getPayload()[ "params" ]
		);
	}

	/**
	 * Returns true if the payload includes a method name.
	 *
	 * @return Boolean
	 */
	private function hasPayloadMethod(){
		return this.hasPayload() && structKeyExists( this.getPayload(), "method" );
	}

	/**
	 * Returns the method defined in the current payload.
	 *
	 * @return String
	 */
	private function getPayloadMethod(){
		return this.getPayload()[ "method" ];
	}

}
