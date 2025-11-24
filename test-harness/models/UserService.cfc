component accessors="true" singleton {

	/*********************************************************************************************/
	/** DI **/
	/*********************************************************************************************/

	property name="populator" inject="wirebox:populator";
	property name="wirebox"   inject="wirebox";

	testUsers = {
		"admin" : {
			"id"			: 1,
			"firstName"		: "Admin",
			"lastName"		: "User",
			"username"		: "admin",
			"password"		: "admin123",
			"roles"			: [ "admin", "user" ],
			"permissions"	: [ "read", "write", "delete" ]
		},
		"user" : {
			"id"			: 2,
			"firstName"		: "Basic",
			"lastName"		: "User",
			"username"		: "user",
			"password"		: "user123",
			"roles"			: [ "user", "editor" ],
			"permissions"	: [ "read" ]
		}
	};

	/**
	 * Constructor
	 */
	function init(){
		return this;
	}

	/**
	 * New User Dispenser
	 */
	user function new() provider="user"{
	}

	/**
	 * Get a new user by id
	 *
	 * @id The id to get the user with
	 *
	 * @return The located user or a new un-loaded user object
	 */
	user function retrieveUserById( required id ){
		var userID = arguments.id;
		// find user by id
		var user = variables.testUsers.filter( function( key, value ){
			return value.id == userID;
		} );
		return user.keyArray().len() ?
			populator.populateFromStruct( new(), user[ user.keyArray()[1] ] ) :
			new();
	}

	/**
	 * Get a user by username
	 *
	 * @username The username to get the user with
	 *
	 * @return The valid user object representing the username or an empty user object
	 */
	user function retrieveUserByUsername( required username ){
		return variables.testUsers.keyExists( arguments.username ) ?
			populator.populateFromStruct( new(), variables.testUsers[ arguments.username ] ) :
			new();
	}

	/**
	 * Verify if the incoming username and password are valid credentials in this user storage
	 *
	 * @username The username to test
	 * @password The password to test
	 *
	 * @return true if valid, else false
	 */
	boolean function isValidCredentials( required username, required password ){
		var oUser = retrieveUserByUsername( arguments.username );
		if ( !oUser.isLoaded() ) {
			return false;
		}
		// NO HASING FOR TESTING PURPOSES ONLY
		return arguments.password eq oUser.getPassword();
	}

}
