component{

	// Configure ColdBox Application
	function configure(){

		// coldbox directives
		coldbox = {
			//Application Setup
			appName 				= "Module Tester",

			//Development Settings
			reinitPassword			= "",
			handlersIndexAutoReload = true,
			modulesExternalLocation = [],

			//Implicit Events
			defaultEvent			= "examples.index",
			requestStartHandler		= "",
			requestEndHandler		= "",
			applicationStartHandler = "",
			applicationEndHandler	= "",
			applicationHelper       = "/includes/helpers/applicationHelper.cfm",
			sessionStartHandler 	= "",
			sessionEndHandler		= "",
			missingTemplateHandler	= "",

			//Error/Exception Handling
			exceptionHandler		= "",
			onInvalidEvent			= "",
			customErrorTemplate 	= "/coldbox/system/exceptions/Whoops.cfm",

			//Application Aspects
			handlerCaching 			= false,
			eventCaching			= false
		};

		// environment settings, create a detectEnvironment() method to detect it yourself.
		// create a function with the name of the environment so it can be executed if that environment is detected
		// the value of the environment is a list of regex patterns to match the cgi.http_host.
		environments = {
			development = "localhost,127\.0\.0\.1"
		};

		// Module Directives
		modules = {
			// An array of modules names to load, empty means all of them
			include = [],
			// An array of modules names to NOT load, empty means none
			exclude = []
		};

		//Register interceptors as an array, we need order
		interceptors = [
		];

		// LogBox DSL
		logBox = {
			// Define Appenders
			appenders : {
				files : {
					class      : "coldbox.system.logging.appenders.RollingFileAppender",
					properties : {
						filename : "tester",
						filePath : "/#appMapping#/logs"
					}
				},
				console : { class : "coldbox.system.logging.appenders.ConsoleAppender" }
			},
			// Root Logger
			root  : { levelmax : "DEBUG", appenders : "*" },
			// Implicit Level Categories
			info  : [ "coldbox.system" ]
		};

		moduleSettings = {
			"cbwire" = {
				"autoInjectAssets"		: true,
				"enableTurbo"			: true,
				"cacheSingleFileComponents": false
			},
			"cbi18n": {
				// The default resource to load and aliased as `default`
				"defaultResourceBundle" : "includes/i18n/",
				// The locale to use when none defined
				"defaultLocale"         : "en_US",
				// The default storage for the locale
				"localeStorage"         : "cookieStorage@cbstorages",
				// What to emit to via the resource methods if a translation is not found
				"unknownTranslation"    : "**NOT FOUND**",
				// If true, we will log to LogBox the missing translations
				"logUnknownTranslation" : true,
				// A-la-carte resources to load by name
				"resourceBundles"       : {},
				// Your own CFC instantiation path
				"customResourceService" : ""
			}
		};

	}

	/**
	 * Load the Module you are testing
	 */
	function afterAspectsLoad( event, interceptData, rc, prc ){
		controller.getModuleService()
			.registerAndActivateModule(
				moduleName 		= request.MODULE_NAME,
				invocationPath 	= "moduleroot"
			);
	}

}