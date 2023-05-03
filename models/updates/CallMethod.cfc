component extends="WireUpdate" {

	property name="cbwireRequest" inject="CBWireRequest@cbwire";

	/**
	 * Runs the specified action method within the request payload on the provided component.
	 *
	 * @return Void
	 */
	function apply( required comp ){
		var engine = arguments.comp.getEngine();

		arguments.comp._renderComputedProperties();

		if ( getPayloadMethod() == "finishUpload" ) {
			arguments.comp._finishUpload( params = getPassedParamsAsArguments() );
			return;
		}
		if ( getPayloadMethod() == "startUpload" ) {
			var dataProperty = getPassedParamsAsArguments()[ 1 ];
			var signature = "someSignature";
			var signedURL = "/livewire/upload-file?expires=never&signature=#signature#";
			comp.emitSelf( eventName = "upload:generatedSignedUrl", parameters = [ dataProperty, signedURL ] );
			return;
		}

		if ( getPayloadMethod() == "$set" ) {
			invoke(
				arguments.comp,
				"set" & getPassedParamsAsArguments()[ 1 ],
				[ getPassedParamsAsArguments()[ 2 ] ]
			);
			return;
		}

		if ( getPayloadMethod() == "$refresh" ) {
			invoke( arguments.comp, "refresh", getPassedParamsAsArguments() );
			return;
		}

		if ( hasCallableAction( arguments.comp ) ) {
			try {
				invoke( arguments.comp, getPayloadMethod(), getPassedParamsAsArguments() );
			} catch ( ValidationException validateException ) {
				// Silently stop further action processing on validationOrFail() exceptions.
			}
			return;
		}

		// We cannot locate the action, so throw an error.
		throw(
			type = "WireActionNotFound",
			message = "Wire action '" & getPayloadMethod() & "' not found on your component."
		);
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
		return hasPayloadMethod() && arguments.comp._hasMethod( getPayloadMethod() );
	}

	/**
	 * Returns the passed parameters as a key value struct instead of an array.
	 *
	 * @return Struct
	 */
	private function getPassedParamsAsArguments(){
		return hasPassedParams() ? getPassedParams() : [];
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

	/**
	 * Returns the the sites base URL.
	 * Used for building URLs returned to Livewire.
	 *
	 * @return String
	 */
	private function getBaseURL(){
		return cgi.http_port == 80 ? "http://" & cgi.http_host : "https://" & cgi.http_host;
	}

}
