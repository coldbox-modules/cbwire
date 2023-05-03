component extends="coldbox.system.FrameworkSupertype" accessors="true" {

	/**
	 * Inject ColdBox, needed by FrameworkSuperType
	 */
	property name="controller" inject="coldbox";

	/**
	 * The CBWIRE component
	 */
	property name="wire";

	/**
	 * Determines if component should be rendered or not.
	 */
	property name="noRendering" default="false";

	/**
	 * The default data struct for cbwire components.
	 * This should be overidden in the child component
	 * with data properties.
	 */
	property name="dataProperties";

	/**
	 * Holds component metadata.
	 */
	property name="meta";

	/**
	 * A beautiful constructor
	 */
	function init( required wire ){
		setWire( arguments.wire );
		setDataProperties( {} );
	}

	/**
	 * Returns true if the provided method name can be found on our component.
	 *
	 * @methodName String | The method name we are checking.
	 * @return Boolean
	 */
	function hasMethod( required methodName ){
		return structKeyExists( getWire(), arguments.methodName );
	}

	/**
	 * Renders our component's view.
	 *
	 * @return Void
	 */
	function renderIt(){
		var cbwireComponent = getWire();
		return cbwireComponent.view( view = cbwireComponent.getTemplatePath() );
	}

	/**
	 * Render out our component's view
	 *
	 * @view The the view to render, if not passed, then we look in the request context for the current set view.
	 * @args A struct of arguments to pass into the view for rendering, will be available as 'args' in the view.
	 * @module The module to render the view from explicitly
	 * @cache Cached the view output or not, defaults to false
	 * @cacheTimeout The time in minutes to cache the view
	 * @cacheLastAccessTimeout The time in minutes the view will be removed from cache if idle or requested
	 * @cacheSuffix The suffix to add into the cache entry for this view rendering
	 * @cacheProvider The provider to cache this view in, defaults to 'template'
	 * @collection A collection to use by this Renderer to render the view as many times as the items in the collection (Array or Query)
	 * @collectionAs The name of the collection variable in the partial rendering.  If not passed, we will use the name of the view by convention
	 * @collectionStartRow The start row to limit the collection rendering with
	 * @collectionMaxRows The max rows to iterate over the collection rendering with
	 * @collectionDelim  A string to delimit the collection renderings by
	 * @prePostExempt If true, pre/post view interceptors will not be fired. By default they do fire
	 * @name The name of the rendering region to render out, Usually all arguments are coming from the stored region but you override them using this function's arguments.
	 *
	 * @return The rendered view
	 */
	function view(
		view = "",
		struct args = {},
		module = "",
		boolean cache = false,
		cacheTimeout = "",
		cacheLastAccessTimeout = "",
		cacheSuffix = "",
		cacheProvider = "template",
		collection,
		collectionAs = "",
		numeric collectionStartRow = "1",
		numeric collectionMaxRows = 0,
		collectionDelim = "",
		boolean prePostExempt = false,
		name
	){
		// Pass the properties of the cbwire component as variables to the view
		arguments.args = getWire()._getState( includeComputed = true );

		// If there are any rendering overrides ( like during file upload ), then merge those in
		structAppend( arguments.args, getWire()._getRenderingOverrides(), true );

		// Provide validation results, either validation results we captured from our action or run them now.
		arguments.args[ "validation" ] = isNull( getWire().getValidationResult() ) ? getWire()._validate() : getWire().getValidationResult();

		// Include a reference to the component's id
		arguments.args[ "_id" ] = getWire().get_id();

		/*
			Store our latest rendered id in the request scope so that it can be
			read by the entangle() method.
		*/
		getWire().getCBWireRequest().getEvent().setPrivateValue( "cbwire_lastest_rendered_id", getWire().get_id() );

		arguments.args[ "computed" ] = getWire()._getComputedProperties();

		if ( structKeyExists( getWire(), "onRender" ) ) {
			// Render custom onRender method
			var result = getWire().onRender( args = arguments.args );
		} else {
			if ( structKeyExists( getWire(), "template" ) ) {
				arguments.view = getWire().template;
			}
			// Render our view using coldbox rendering
			var result = super.renderView( argumentCollection = arguments );
		}

		return result;
	}

}
