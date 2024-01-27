/*
	There is code duplication here, but I'm not sure how to avoid it.
	We need to be able to parse the arguments passed to the emit() and emitTo() methods
	and there are differences between how Lucee and Adobe CF handle the arguments.

	Creating separate functions for each method allows us to handle the differences
	here.
*/
component accessors="true" {

	property name="caller";

	function parseEmitParameters( required eventName ) {

		var selfArguments = arguments;

		return selfArguments
			.keyList()
			.listToArray()
			// Remove any arguments called "eventName" from the list
			.filter( function( value ) {
				return value != "eventName" && value != "componentName";
			} )
			// Sort the arguments by their numeric value
			.sort( "numeric" )
			// Convert the sorted list back to an ordered struct
			.reduce( function( acc, value, index ) {
				acc[ value ] = selfArguments[value];
				return acc;
			}, [:] )
			// Filter out any null or object values
			.filter( function( key, value ) {
				return !isNull( value ) && !isObject( value );
			} )
			// Convert the struct to an array which makes up our parameters
			.reduce( function( acc, key, value, thisStruct ) {
				acc.append( value );
				return acc;
			}, [] );
	}

	function parseEmitToParameters( required componentName, required eventName ) {
		var selfArguments = arguments;

		return selfArguments
			.keyList()
			.listToArray()
			// Remove any arguments called "eventName" from the list
			.filter( function( value ) {
				return value != "eventName" && value != "componentName";
			} )
			// Sort the arguments by their numeric value
			.sort( "numeric" )
			// Convert the sorted list back to an ordered struct
			.reduce( function( acc, value, index ) {
				acc[ value ] = selfArguments[value];
				return acc;
			}, [:] )
			// Filter out any null or object values
			.filter( function( key, value ) {
				return !isNull( value ) && !isObject( value );
			} )
			// Convert the struct to an array which makes up our parameters
			.reduce( function( acc, key, value, thisStruct ) {
				acc.append( value );
				return acc;
			}, [] );
	}

}
