component extends="coldbox.system.testing.BaseTestCase" {

    // Lifecycle methods and BDD suites as before...

    function run(testResults, testBox) {
        describe("Component.cfc", function() {

            beforeEach(function(currentSpec) {
                // Assuming setup() initializes application environment
                // and prepareMock() is a custom method to mock any dependencies, if necessary.
                setup();
                testComponent = getInstance("wires.TestComponent");
                testComponent._withEvent( getRequestContext( ) );
                prepareMock( testComponent );
            });

            it("is an object", function() {
                expect(isObject(testComponent)).toBeTrue();
            });

            it("has generated getter", function() {
                expect(testComponent.getModules()).toBeArray();
            });

            it("has generated setter", function() {
                testComponent.setModules( [ "cbwire", "quickorm" ] );
                expect(testComponent.getModules().len()).toBe(2);
            });

            it( "can call getInstance()", function() {
                var result = testComponent.getInstance( "wires.TestComponent" );
                expect( result ).toBeInstanceOf( "TestComponent" );
            } );

            it("can call action", function() {
                testComponent.setFrameworks( [ "cbwire", "coldbox" ] );
                testComponent.clearFrameworks();
                expect(testComponent.getFrameworks().len()).toBe(0);
            });

            it("renders with correct snapshot, effects, and id attribute", function() {
                var renderedHtml = testComponent.renderIt();
                expect(renderedHtml.contains('<div wire:snapshot="{')).toBeTrue();
                expect(renderedHtml.contains('wire:effects="[]')).toBeTrue();
                expect(renderedHtml.contains('id="')).toBeTrue();
            });

            it("renders string booleans as booleans", function() {
                var renderedHtml = testComponent.renderIt();
                expect(renderedHTML.contains('isMarvel&quot;:true') ).toBeTrue();
            });

            it("can render a view template", function() {
                testComponent.addModule("CBWIRE");
                var viewContent = testComponent.view("wires.testcomponent");
                expect(viewContent).toInclude("Modules");
                expect(viewContent).toInclude("CBWIRE");
            });

            it("can implicitly render a view template", function() {
                testComponent = getInstance("wires.ImplicitRender");
                var viewContent = testComponent.renderIt();
                expect(viewContent).toInclude("I rendered implicitly");
            });

            it("can pass additional data to the view", function() {
                var viewContent = testComponent.view("wires.TestComponent", { modules: [ "wirebox"] });
                expect(viewContent).toInclude("wirebox");
            });

            it( "supports computed properties", function() {
                expect( testComponent.numberOfModules() ).toBe( 0 );
            } );

            it( "computed properties are cached", function() {
                var strength1 = testComponent.calculateStrength();
                sleep( 10 );
                var strength2 = testComponent.calculateStrength();
                expect( strength1 ).toBe( strength2 );
            } );

            it( "computed properties can accept false flag to prevent caching", function() {
                var strength1 = testComponent.calculateStrength();
                sleep( 10 );
                var strength2 = testComponent.calculateStrength( false );
                expect( strength1 ).notToBe( strength2 );
            } );

            it( "returns a snapshot that contains the proper memo name", function() {
                var snapshot = testComponent._getSnapshot();
                expect( snapshot.memo.name ).toBe( "TestComponent" );
                expect( snapshot.memo.path ).toBe( "TestComponent" );
            } );

            it( "computed property can be accessed from view", function() {
                testComponent.addModule( "CBWIRE" );
                testComponent.addModule( "CBORM" );
                var viewContent = testComponent.view("wires.TestComponent" );
                expect(viewContent).toInclude("Number Of Modules: 2");
            } );

            it( "data properties can be accessed from view using args.", function() {
                testComponent.addModule( "CBWIRE" );
                testComponent.addModule( "CBORM" );
                var viewContent = testComponent.view("wires.TestComponentUsingArgs" );
                expect(viewContent).toInclude("Number Of Modules: 2");
            } );

            it( "throws error if we try to set a dataproperty that doesn't exist", function() {
                expect(function() {
                    testComponent.setCount( 1000 );
                }).toThrow( type="CBWIREException" );
            } );

            it( "can reset all data properties", function() {
                testComponent.addModule( "ContentBox" );
                testComponent.reset();
                expect( testComponent.numberOfModules() ).toBe( 0 );
            } );

            it( "can reset a single data property", function() {
                testComponent.addModule( "CBWIRE" );
                testComponent.addFramework( "ColdBox" );
                testComponent.reset( "modules" );
                expect( testComponent.numberOfModules() ).toBe( 0 );
                expect( testComponent.numberOfFrameworks() ).toBe( 1 );
            } );

            it( "can reset multiple data properties", function() {
                testComponent.addModule( "CBWIRE" );
                testComponent.addFramework( "ColdBox" );
                testComponent.reset( [ "modules", "frameworks" ] );
                expect( testComponent.numberOfModules() ).toBe( 0 );
                expect( testComponent.numberOfFrameworks() ).toBe( 0 );
            } );

            it( "can resetExcept a single data property", function() {
                testComponent.addModule( "CBWIRE" );
                testComponent.addFramework( "ColdBox" );
                testComponent.resetExcept( "modules" );
                expect( testComponent.numberOfModules() ).toBe( 1 );
                expect( testComponent.numberOfFrameworks() ).toBe( 0 );
            } );

            it( "can resetExcept multiple data properties", function() {
                testComponent.addModule( "CBWIRE" );
                testComponent.addFramework( "ColdBox" );
                testComponent.resetExcept( [ "modules" ] );
                expect( testComponent.numberOfModules() ).toBe( 1 );
                expect( testComponent.numberOfFrameworks() ).toBe( 0 );
            } );

            it( "can render child components", function() {
                testComponent.setShowStats( true );
                var result = testComponent.view( "wires.TestComponent" );
                expect( result ).toInclude( "&quot;super-hero" );
            } );

            describe( "Preprocessors", function() {               
                it( "provide teleport and endTeleport methods", function() {
                    var result = testComponent.view( "wires.testing.teleport" );
                    expect( result ).toInclude( "<template x-teleport=""##someId"">" );
                    expect( result ).toInclude( "</template>" );
                } );
            } );

            it( "can validate()", function() {
                var result = testComponent.validate();
                expect( result ).toBeInstanceOf( "ValidationResult" );
                expect( result.hasErrors() ).toBeTrue();
            } );

            it("can access validation from view", function() {
                var result = testComponent.validate();
                var viewContent = testComponent.view("wires.superheroesvalidation");
                expect(viewContent).toInclude("The 'mailingList' has an invalid type, expected type is email");
            });

            it( "auto validates", function() {
                var viewContent = testComponent.view("wires.superheroesvalidation");
                expect(viewContent).toInclude("The 'mailingList' has an invalid type, expected type is email");
            } );

            it( "can validateOrFail", function() {
                expect(function() {
                    testComponent.validateOrFail();
                }).toThrow( type="ValidationException" );

                testComponent.setMailingList( "user@somedomain.com" );
                expect( testComponent.validateOrFail() ).toBeInstanceOf( "ValidationResult" );
            } );

            it( "can hasError( field)", function() {
                testComponent.validate();
                expect( testComponent.hasErrors( "mailingList" ) ).toBeTrue();
            } );

            it( "can entangle", function() {
                var result = testComponent.entangle( "mailingList" );
                expect( result ).toInclude( "window.Livewire.find" );
                expect( result ).toInclude( "entangle( 'mailingList' )");
            } );

            it( "can reference application helper methods", function() {
                var result = testComponent.view( "wires.testcomponentwithhelpermethods" );
                expect( result ).toInclude( "someGlobalUDF: yay!" );
            } );

            xit("throws an exception for a non-existent view", function() {
                expect(function() {
                    testComponent.view("nonExistentView.cfm");
                }).toThrow();
            });

            xit("throws an error for HTML without a single outer element", function() {
                // Override MyComponent's view method to return HTML without a single outer element for this test
                testComponent.$("_renderViewContent", "<div>First Element</div><div>Second Element</div>" );

                expect(function() {
                    testComponent.renderIt();
                }).toThrow("The rendered HTML must have a single outer element.");
            });

        });

        describe("Incoming Requests", function() {

            beforeEach(function(currentSpec) {
                // Assuming setup() initializes application environment
                // and prepareMock() is a custom method to mock any dependencies, if necessary.
                setup();
                cbwireController = getInstance("CBWIREController@cbwire");
                event = getRequestContext();
                prepareMock( cbwireController );
            });

            it( "provides a handleRequest() method that returns subsequent payloads", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "counter",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "incrementBy",
                            "params": [ 10 ]
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( isStruct( response ) ).toBeTrue();
            } );

            it( "returns the same id", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "counter",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "incrementBy",
                            "params": [ 10 ]
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( deserializeJson( response.components[1].snapshot ).memo.id ).toBe( "Z1Ruz1tGMPXSfw7osBW2" );
            } );

            it( "runs action we pass it", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "counter",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "increment",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "Counter: 2" );
            } );

            it( "runs action we pass it with parameters", function() {  
                var payload = incomingRequest(
                    memo = {
                        "name": "counter",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "incrementBy",
                            "params": [ 10 ]
                        }
                    ],
                    updates = {}
                );
                
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "Counter: 11" );
            } );

            it( "returns an outer element with the same id that we passed in", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "counter",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "increment",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "id=""Z1Ruz1tGMPXSfw7osBW2""" );
            } );

            it( "can provide updates to data properties", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "counter",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "count": 1
                    },
                    calls = [],
                    updates = {
                        "count": 100
                    }
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "Counter: 100" );
            } );

            it( "can dispatch an event without params", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "counter",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "increment",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.dispatches ).toBeArray();
                expect( response.components[1].effects.dispatches[1].name ).toBe( "incremented" );
                expect( arrayLen( response.components[1].effects.dispatches[1].params ) ).toBe( 0 );
            } );

            it( "can dispatch an event with params", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "counter",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "incrementBy",
                            "params": [10]
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.dispatches ).toBeArray();
                expect( response.components[1].effects.dispatches[1].name ).toBe( "incrementedBy" );
                expect( response.components[1].effects.dispatches[1].params[1] ).toBe( 10 );
            } );

            it( "can dispatchSelf()", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "counter",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "incrementDispatchSelf",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.dispatches ).toBeArray();
                expect( response.components[1].effects.dispatches[1].name ).toBe( "incremented" );
                expect( arrayLen( response.components[1].effects.dispatches[1].params ) ).toBe( 0 );
                expect( response.components[1].effects.dispatches[1].self ).toBeTrue();
            } );

            it( "should track child components on the response", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "counter",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": {
                            "data-binding": [ "div", "dsfsadfasdfsdf" ]
                        }
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "incrementDispatchSelf",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                var snapshot = deserializeJson( response.components[ 1 ].snapshot );
                expect( snapshot.memo.children.count() ).toBe( 1 );
            } );

            it( "should call onHydrate() if it exists", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "OnHydrate",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "hydrated": false,
                        "hydratedProperty": false
                    },
                    calls = [],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "Hydrated: true" );
            } );

            it( "should call onHydrate[Property] if it exists", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "OnHydrate",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {
                        "hydrated": false,
                        "hydratedProperty": false
                    },
                    calls = [],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.html ).toInclude( "Hydrated Property: true" );
            } );

            it( "should be able to return javascript to return", () => {
                var payload = incomingRequest(
                    memo = {
                        "name": "TestComponent",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [
                        {
                            "path": "",
                            "method": "runJSMethod",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.xjs ).toBeArray();
                expect( response.components[1].effects.xjs.first() ).toBe( "alert('Hello from CBWIRE!');" );
            } );

            it( "it should track return values", () => {
                var payload = incomingRequest(
                    memo = {
                        "name": "TestComponent",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [
                        {
                            "path": "",
                            "method": "runActionWithReturnValue",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.returns ).toBeArray();
                expect( response.components[1].effects.returns.first() ).toBe( "Return from CBWIRE!" );
            } );

            xit( "should be able to stream()", () => {
                var payload = incomingRequest(
                    memo = {
                        "name": "TestComponent",
                        "id": "Z1Ruz1tGMPXSfw7osBW2",
                        "children": []
                    },
                    data = {},
                    calls = [
                        {
                            "path": "",
                            "method": "runStream",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );

                writeDump( response );
                abort;
                expect( response.components[1].effects.streams ).toBeArray();
                expect( response.components[1].effects.streams.first() ).toBe( "streaming" );
            } );

            xit( "can dispatchTo()", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "counter",
                        "id": "Z1Ruz1tGMPXSfw7osBW2"
                    },
                    data = {
                        "count": 1
                    },
                    calls = [
                        {
                            "path": "",
                            "method": "incrementDispatchTo",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload, event );
                expect( response.components[1].effects.dispatches ).toBeArray();
                expect( response.components[1].effects.dispatches[1].name ).toBe( "incremented" );
                expect( arrayLen( response.components[1].effects.dispatches[1].params ) ).toBe( 0 );
                expect( response.components[1].effects.dispatches[1].self ).toBeTrue();
            } );
        } );

        describe("Component.cfc Lazy Loading", function() {
            beforeEach(function(currentSpec) {
                // Setup initializes application environment and mocks dependencies
                setup();
                testComponent = getInstance("wires.TestComponent"); // Assuming TestComponent is a component that supports lazy loading
                testComponent._withEvent(getRequestContext());
                prepareMock(testComponent);
            });

            it("returns a base64-encoded lazy loading snapshot when wire() is called with lazy=true", function() {
                var lazyHtml = testComponent.wire(
                    name="TestComponent",
                    params={},
                    key="",
                    lazy=true
                );
                // Check if the returned HTML contains a base64-encoded snapshot and lazy load attributes
                expect(lazyHtml).toInclude("x-intersect=");
                expect(lazyHtml).toInclude("wire:snapshot=");
                expect(lazyHtml).toInclude("Test Placeholder");
            });

            it("does not immediately render the component's content when lazy is true", function() {
                var lazyHtml = testComponent.wire(
                    name="TestComponent",
                    params={},
                    key="",
                    lazy=true
                );
                // Check that the actual component content is not included in the output
                expect(lazyHtml).notToInclude("Actual Component Content");
            });
        });

        describe("CBWIREController", function() {

            beforeEach(function(currentSpec) {
                // Assuming setup() initializes application environment
                // and prepareMock() is a custom method to mock any dependencies, if necessary.
                setup();
                cbwireController = getInstance("CBWIREController@cbwire");
                prepareMock( cbwireController );
            });

            it( "returns an object", function() {
                expect( isObject( cbwireController ) ).toBeTrue();
            } );

            it( "provides a wire() method that returns html", function() {
                var html = cbwireController.wire(
                    name="Counter",
                    params={},
                    key=""
                );
                expect( html ).toInclude( "wire:snapshot" );
                expect( html ).toInclude( "wire:effects" );
            } );

            it( "wire() method automatically sets passed params", function() {
                var html = cbwireController.wire(
                    name="TestComponent",
                    params={ "title": "Override title" }
                );
                expect( html ).toInclude( "Title: Override title" );
            } );

            it( "wire() method passes params to onMount if it exists", function() {
                var html = cbwireController.wire(
                    name="CounterWithOnMount",
                    params={ "count": 1000 },
                    key=""
                );
                expect( html ).toInclude( "Counter: 1000" );
            } );
        });

        describe( "Preprocessors", function() {
            describe( "CBWIREPreprocessor", function() {
                beforeEach(function(currentSpec) {
                    // Assuming setup() initializes application environment
                    // and prepareMock() is a custom method to mock any dependencies, if necessary.
                    setup();
                    preprocessor = getInstance("CBWIREPreprocessor@cbwire");
                    prepareMock( preprocessor );
                });
    
                it("parses and replaces single cbwire tag with no arguments", function() {
                    var input = "<cbwire:testComponent/>";
                    var expected = "##wire( name=""testComponent"", params={ }, lazy=false )##";
                    var result = preprocessor.handle(input);
                    expect(result).toBe(expected);
                });
    
                it("parses and replaces cbwire tag with multiple arguments", function() {
                    var input = "<cbwire:testComponent :param1='value1' param2='value2'/>";
                    var expected = "##wire( name=""testComponent"", params={ param1=value1, param2='value2' }, lazy=false )##";
                    var result = preprocessor.handle(input);
                    expect(result).toBe(expected);
                });
    
                it("correctly handles arguments with expressions", function() {
                    var input = "<cbwire:testComponent :expr='someExpression'/>";
                    var expected = "##wire( name=""testComponent"", params={ expr=someExpression }, lazy=false )##";
                    var result = preprocessor.handle(input);
                    expect(result).toBe(expected);
                });
    
                it("maintains order and syntax of multiple attributes", function() {
                    var input = "<cbwire:testComponent attr1='foo' :expr='bar' attr2='baz'/>";
                    var expected = "##wire( name=""testComponent"", params={ attr1='foo', expr=bar, attr2='baz' }, lazy=false )##";
                    var result = preprocessor.handle(input);
                    expect(result).toBe(expected);
                });
    
                it("replaces multiple cbwire tags in a single content string", function() {
                    var input = "Here is a test <cbwire:firstComponent attr='value'/> and another <cbwire:secondComponent :expr='expression'/>";
                    var expected = "Here is a test ##wire( name=""firstComponent"", params={ attr='value' }, lazy=false )## and another ##wire( name=""secondComponent"", params={ expr=expression }, lazy=false )##";
                    var result = preprocessor.handle(input);
                    expect(result).toBe(expected);
                }); 

                it("throws an exception for unparseable tags", function() {
                    var input = "<cbwire:testComponent :broken='noEndQuote>";
                    expect(function() {
                        preprocessor.handle(input);
                    }).toThrow( message="Parsing error: unable to process cbwire tag due to malformed attributes.");
                });

            } );

            describe("Teleport Preprocessing Tests", function() {

                beforeEach(function() {
                    // Create an instance of the component that handles teleport preprocessing
                    preprocessor = getInstance( "TeleportPreprocessor@cbwire" );
                });
    
                it("should replace @teleport with the correct template tag", function() {
                    var content = "@teleport(selector) content @endteleport";
                    var expected = '<template x-teleport="selector"> content </template>';
                    var result = preprocessor.handle(content);
                    expect(result).toBe(expected);
                });
    
                it("should handle single quotes around the selector", function() {
                    var content = "@teleport('selector') content @endteleport";
                    var expected = '<template x-teleport="selector"> content </template>';
                    var result = preprocessor.handle(content);
                    expect(result).toBe(expected);
                });
    
                it("should handle double quotes around the selector", function() {
                    var content = '@teleport("selector") content @endteleport';
                    var expected = '<template x-teleport="selector"> content </template>';
                    var result = preprocessor.handle(content);
                    expect(result).toBe(expected);
                });
    
                it("should handle no quotes around the selector", function() {
                    var content = "@teleport(selector) content @endteleport";
                    var expected = '<template x-teleport="selector"> content </template>';
                    var result = preprocessor.handle(content);
                    expect(result).toBe(expected);
                });
    
                it("should handle spaces within the parentheses", function() {
                    var content = "@teleport(   selector   ) content @endteleport";
                    var expected = '<template x-teleport="selector"> content </template>';
                    var result = preprocessor.handle(content);
                    expect(result).toBe(expected);
                });
    
                it("should handle multiple teleport directives in the same content", function() {
                    var content = "@teleport(selector1) content1 @endteleport @teleport(selector2) content2 @endteleport";
                    var expected = '<template x-teleport="selector1"> content1 </template> <template x-teleport="selector2"> content2 </template>';
                    var result = preprocessor.handle(content);
                    expect(result).toBe(expected);
                });
    
                it("should handle nested teleport directives", function() {
                    var content = "@teleport(outer) @teleport(inner) content @endteleport @endteleport";
                    var expected = '<template x-teleport="outer"> <template x-teleport="inner"> content </template> </template>';
                    var result = preprocessor.handle(content);
                    expect(result).toBe(expected);
                });
    
                it("should not alter content without teleport directives", function() {
                    var content = "Normal content without directives";
                    var result = preprocessor.handle(content);
                    expect(result).toBe(content);
                });
            });

        } );
    }

    /**
     * Helper test method for creating incoming request payloads
     *
     * @data 
     * @calls
     * 
     * @return struct
     */
    private function incomingRequest(
        memo = {},
        data = {},
        calls = [],
        updates = {}
    ){

        var response = {
            "content": {
                "components": [
                    {
                        "calls": arguments.calls,
                        "snapshot": {
                            "data": arguments.data,
                            "memo": arguments.memo
                        },
                        "updates": arguments.updates
                    }
                ]
            }
        };

        response.content.components = response.content.components.map( function( _comp ) {
            _comp.snapshot = serializeJson( _comp.snapshot );
            return _comp;
        } );

        response.content = serializeJson( response.content );

        return response;
    }
}
