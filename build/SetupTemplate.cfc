
/**
 * Setup the Module Template according to your needs
 */
component {

	/**
	 * Constructor
	 */
	function init(){
		// Setup Pathing
		variables.cwd          = getCWD().reReplace( "\.$", "" );
		return this;
	}

	/**
	 * Setup the module template
	 */
	function run(){

		var moduleName = ask( "What is the human readable name of your module?" );
		if( !len( moduleName ) ){
			error( "Module Name is required" );
		}
		var moduleSlug = ask( "What is the slug for your module?" );
		if( !len( moduleSlug ) ){
			error( "Module Slug is required" );
		}
		var moduleDescription = ask( "Short description of your module?" );
		if( !len( moduleDescription ) ){
			error( "Module Description is required" );
		}

		command( "tokenReplace" )
			.params(
				path        = "/#variables.cwd#/**",
				token       = "@MODULE_NAME@",
				replacement = moduleName
			)
			.run();

		command( "tokenReplace" )
			.params(
				path        = "/#variables.cwd#/**",
				token       = "@MODULE_SLUG@",
				replacement = moduleSlug
			)
			.run();

		command( "tokenReplace" )
			.params(
				path        = "/#variables.cwd#/**",
				token       = "@MODULE_DESCRIPTION@",
				replacement = moduleDescription
			)
			.run();

		// Finalize Message
		print
			.line()
			.boldMagentaLine( "Your module template is now ready for development! Go rock it!" )
			.toConsole();
	}

	/**
	 * Build the source
	 *
	 * @projectName The project name used for resources and slugs
	 * @version The version you are building
	 * @buldID The build identifier
	 * @branch The branch you are building
	 */
	function buildSource(
		required projectName,
		version = "1.0.0",
		buildID = createUUID(),
		branch  = "development"
	){
		// Build Notice ID
		print
			.line()
			.boldMagentaLine(
				"Building #arguments.projectName# v#arguments.version#+#arguments.buildID# from #cwd# using the #arguments.branch# branch."
			)
			.toConsole();

		// Prepare exports directory
		variables.exportsDir = variables.artifactsDir & "/#projectName#/#arguments.version#";
		directoryCreate( variables.exportsDir, true, true );

		// Project Build Dir
		variables.projectBuildDir = variables.buildDir & "/#projectName#";
		directoryCreate(
			variables.projectBuildDir,
			true,
			true
		);

		// Copy source
		print.blueLine( "Copying source to build folder..." ).toConsole();
		copy(
			variables.cwd,
			variables.projectBuildDir
		);

		// Create build ID
		fileWrite(
			"#variables.projectBuildDir#/#projectName#-#version#+#buildID#",
			"Built with love on #dateTimeFormat( now(), "full" )#"
		);

		// Updating Placeholders
		print.greenLine( "Updating version identifier to #arguments.version#" ).toConsole();
		command( "tokenReplace" )
			.params(
				path        = "/#variables.projectBuildDir#/**",
				token       = "@build.version@",
				replacement = arguments.version
			)
			.run();

		print.greenLine( "Updating build identifier to #arguments.buildID#" ).toConsole();
		command( "tokenReplace" )
			.params(
				path        = "/#variables.projectBuildDir#/**",
				token       = ( arguments.branch == "master" ? "@build.number@" : "+@build.number@" ),
				replacement = ( arguments.branch == "master" ? arguments.buildID : "-snapshot" )
			)
			.run();

		// zip up source
		var destination = "#variables.exportsDir#/#projectName#-#version#.zip";
		print.greenLine( "Zipping code to #destination#" ).toConsole();
		cfzip(
			action    = "zip",
			file      = "#destination#",
			source    = "#variables.projectBuildDir#",
			overwrite = true,
			recurse   = true
		);

		// Copy box.json for convenience
		fileCopy(
			"#variables.projectBuildDir#/box.json",
			variables.exportsDir
		);
	}

}
