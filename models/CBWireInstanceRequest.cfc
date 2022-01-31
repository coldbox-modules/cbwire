component {

	/**
	 * Instantiates our cbwire component, mounts it,
	 * and then calls it's internal renderIt() method.
	 *
	 * @cbwireComponent Component | The cbwire component object.
	 * @parameters Struct | The parameters you want mounted initially.
	 *
	 * @return Component
	 */
	function handle(
		required cbwireComponent,
		parameters = {}
	){
		return cbwireComponent.$mount( arguments.parameters ).renderIt();
	}

}
