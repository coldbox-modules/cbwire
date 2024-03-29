component extends="coldbox.system.testing.BaseTestCase" {

	/**
	 * Bootstraps our cbwire component with a suite of test utilities.
	 *
	 * @componentName Name of cbwire component.
	 * @return TestComponentSpec
	 */
	function wire( required componentName, params = {} ){
		return getInstance(
			name = "TestComponentSpec@cbwire",
			initArguments = { componentName : arguments.componentName, parameters : arguments.params }
		);
	}

}
