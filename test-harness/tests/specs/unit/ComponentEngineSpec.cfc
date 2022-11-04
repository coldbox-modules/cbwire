component extends="coldbox.system.testing.BaseTestCase" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		super.beforeAll();
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		describe( "ComponentEngineSpec.cfc", function(){
			beforeEach( function( currentSpec ){
				setup();
				cbwireRequest = prepareMock( getInstance( "CBWireRequest@cbwire" ) );
				componentObj = prepareMock(
					getInstance( name = "Component@cbwire", initArguments = { "cbwireRequest" : cbwireRequest } )
				);
				variablesScope = componentObj.getInternals();
				structAppend(
					variablesScope,
					{
						"data" : componentObj.getEngine().getDataProperties(),
						"computed" : componentObj.getEngine().getComputedProperties()
					}
				);
				engine = prepareMock(
					getInstance(
						name = "ComponentEngine@cbwire",
						initArguments = {
							wire : componentObj,
							variablesScope : variablesScope
						}
					)
				);
				componentObj.setEngine( engine );
			} );

			describe( "renderIt()", function(){
				it( "can render", function(){
					engine.renderIt();
					expect( engine.renderIt() ).toInclude( "Component" );
				} );

				it( "renders args._id", function() {
					engine.renderIt();
					expect( engine.renderIt() ).toInclude( engine.getId() );
				} );

				it( "can render directly from component onRender method", function(){
					componentObj.$( "onRender", "<div>some rendering</div>" );
					expect( engine.renderIt() ).toInclude( "some rendering" );
				} );
			} );
		} );
	}

}
