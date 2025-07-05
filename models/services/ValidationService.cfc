component accessors="true" singleton {

    property name="validationManager" inject="provider:ValidationManager@cbvalidation";

    /**
     * Retrieves an instance of the ValidationManager from WireBox.
     *
     * @return ValidationManager An instance of the cbvalidation ValidationManager.
     * @throws CBWIREException If the cbvalidation module is not found.
     */
    function getManager() {
        try {
            return validationManager.$get();
        } catch ( any e ) {
            throw( type="CBWIREException", message="ValidationManager not found. Make sure the 'cbvalidation' module is installed. #e.message#" );
        }
    }

    /**
     * Checks whether the cbvalidation module is installed and accessible.
     *
     * @return boolean True if the module is available, otherwise false.
     */
    function isCBValidationInstalled() {
        try {
            getManager();
            return true;
        } catch ( any e ) {
            return false;
        }
    }

    /**
     * Validates the given data using cbvalidation. Falls back to component data and constraints if not provided.
     *
     * @wire           The CBWIRE component instance.
     * @target         (optional) The target data to validate. Defaults to the component's data.
     * @fields         (optional) Fields to validate.
     * @constraints    (optional) Constraints to apply. Defaults to the component's constraints.
     * @locale         (optional) Locale to use for validation messages.
     * @excludeFields  (optional) Fields to exclude from validation.
     * @includeFields  (optional) Fields to include in validation.
     * @profiles       (optional) Profiles to use in validation.
     *
     * @return ValidationResult The result of the validation operation.
     */
    function validate( wire, target, fields, constraints, locale, excludeFields, includeFields, profiles ){
        arguments.target = isNull( arguments.target ) ? arguments.wire._getDataProperties() : arguments.target;
        arguments.constraints = isNull( arguments.constraints ) ? arguments.wire._getConstraints() : arguments.constraints;
        return getManager().validate( argumentCollection = arguments );
    }

    /**
     * Validates the component's data and throws an exception if validation fails.
     *
     * @throws ValidationException If validation fails.
     */
    function validateOrFail( required wire ){
        local.validationResults = validate( arguments.wire );
        if ( local.validationResults.hasErrors() ) {
            throw( type="ValidationException", message="Validation failed" );
        }
    }
}
