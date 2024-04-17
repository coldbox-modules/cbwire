component extends="coldbox.system.testing.BaseTestCase" {

    // Lifecycle methods and BDD suites as before...

    function run(testResults, testBox) {
        describe("Component.cfc", function() {

            beforeEach(function(currentSpec) {
                // Assuming setup() initializes application environment
                // and prepareMock() is a custom method to mock any dependencies, if necessary.
                setup();
                comp = getInstance("wires.Counter");
                prepareMock( comp );
            });

            it("is an object", function() {
                expect(isObject(comp)).toBeTrue();
            });

            it("has generated getter", function() {
                expect(comp.getCount()).toBe(1);
            });

            it("has generated setter", function() {
                comp.setCount( 10 );
                expect(comp.getCount()).toBe(10);
            });

            it( "can call getInstance()", function() {
                var result = comp.getInstance( "wires.Counter" );
                expect( result ).toBeInstanceOf( "Counter" );
            } );

            it("increments count", function() {
                comp.increment();
                expect(comp.getCount()).toBe(2);
            });

            it("decrements count", function() {
                comp.decrement();
                expect(comp.getCount()).toBe(0);
            });

            it("renders with correct snapshot, effects, and id attribute", function() {
                var renderedHtml = comp.renderIt();
                expect(renderedHtml.contains('<div wire:snapshot="{')).toBeTrue();
                expect(renderedHtml.contains('wire:effects="[]')).toBeTrue();
                expect(renderedHtml.contains('id="')).toBeTrue();
            });

            it("renders string booleans as booleans", function() {
                var renderedHtml = comp.renderIt();
                expect(renderedHTML.contains('submitted&quot;:false') ).toBeTrue();
            });

            it("can render a view template", function() {
                var viewContent = comp.view("wires.Counter"); // Adjust based on your view's location
                expect(viewContent).toInclude("Counter: 1");
            });

            it("can implicitly render a view template", function() {
                comp = getInstance("wires.ImplicitRender");
                var viewContent = comp.renderIt();
                expect(viewContent).toInclude("I rendered implicitly");
            });

            it("can pass additional data to the view", function() {
                var viewContent = comp.view("wires.Counter", { count: 5 });
                expect(viewContent).toInclude("Counter: 5");
            });

            it( "supports computed properties", function() {
                expect( comp.countPlusTen() ).toBe( 11 );
            } );

            it( "computed properties are cached", function() {
                var result1 = comp.tick();
                sleep( 10 );
                var result2 = comp.tick();
                expect( result1 ).toBe( result2 );
            } );

            it( "computed properties can accept false flag to prevent caching", function() {
                var result1 = comp.tick();
                sleep( 10 );
                var result2 = comp.tick( false );
                expect( result1 ).notToBe( result2 );
            } );

            it( "returns a snapshot that contains the proper memo name", function() {
                var snapshot = comp._getSnapshot();
                expect( snapshot.memo.name ).toBe( "Counter" );
                expect( snapshot.memo.path ).toBe( "Counter" );

            } );

            it( "computed property can be accessed from view", function() {
                var viewContent = comp.view("wires.CounterUsingComputedProperty" );
                expect(viewContent).toInclude("Counter: 11");
            } );

            it( "can reset all data properties", function() {
                comp.setCount( 1000 );
                comp.setSubmitted( true );
                comp.reset();
                expect( comp.getCount() ).toBe( 1 );
                expect( comp.getSubmitted() ).toBe( false );
            } );

            it( "can reset a single data property", function() {
                comp.setCount( 1000 );
                comp.setSubmitted( true );
                comp.reset( "count" );
                expect( comp.getCount() ).toBe( 1 );
                expect( comp.getSubmitted() ).toBe( true );
            } );

            it( "can reset multiple data properties", function() {
                comp.setCount( 1000 );
                comp.setSubmitted( true );
                comp.reset( [ "count", "submitted" ] );
                expect( comp.getCount() ).toBe( 1 );
                expect( comp.getSubmitted() ).toBe( false );
            } );

            it( "can resetExcept a single data property", function() {
                comp.setCount( 1000 );
                comp.setSubmitted( true );
                comp.resetExcept( "count" );
                expect( comp.getCount() ).toBe( 1000 );
                expect( comp.getSubmitted() ).toBe( false );
            } );

            it( "can resetExcept multiple data properties", function() {
                comp.setCount( 1000 );
                comp.setSubmitted( true );
                comp.resetExcept( [ "count" ] );
                expect( comp.getCount() ).toBe( 1000 );
                expect( comp.getSubmitted() ).toBe( false );
            } );


            xit("throws an exception for a non-existent view", function() {
                expect(function() {
                    comp.view("nonExistentView.cfm");
                }).toThrow();
            });

            xit("throws an error for HTML without a single outer element", function() {
                // Override MyComponent's view method to return HTML without a single outer element for this test
                comp.$("_renderViewContent", "<div>First Element</div><div>Second Element</div>" );

                expect(function() {
                    comp.renderIt();
                }).toThrow("The rendered HTML must have a single outer element.");
            });

        });

        describe("Incoming Requests", function() {

            beforeEach(function(currentSpec) {
                // Assuming setup() initializes application environment
                // and prepareMock() is a custom method to mock any dependencies, if necessary.
                setup();
                cbwireController = getInstance("CBWIREController@cbwire");
                prepareMock( cbwireController );
            });

            it( "provides a handleRequest() method that returns subsequent payloads", function() {
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
                            "method": "incrementBy",
                            "params": [ 10 ]
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload );
                expect( isStruct( response ) ).toBeTrue();
            } );

            it( "returns the same id", function() {
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
                            "method": "incrementBy",
                            "params": [ 10 ]
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload );
                expect( deserializeJson( response.components[1].snapshot ).memo.id ).toBe( "Z1Ruz1tGMPXSfw7osBW2" );
            } );

            it( "runs action we pass it", function() {
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
                            "method": "increment",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload );
                expect( response.components[1].effects.html ).toInclude( "Counter: 2" );
            } );

            it( "runs action we pass it with parameters", function() {  
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
                            "method": "incrementBy",
                            "params": [ 10 ]
                        }
                    ],
                    updates = {}
                );
                
                var response = cbwireController.handleRequest( payload );
                expect( response.components[1].effects.html ).toInclude( "Counter: 11" );
            } );

            it( "returns an outer element with the same id that we passed in", function() {
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
                            "method": "increment",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload );
                expect( response.components[1].effects.html ).toInclude( "id=""Z1Ruz1tGMPXSfw7osBW2""" );
            } );

            it( "can provide updates to data properties", function() {
                var payload = incomingRequest(
                    memo = {
                        "name": "counter",
                        "id": "Z1Ruz1tGMPXSfw7osBW2"
                    },
                    data = {
                        "count": 1
                    },
                    calls = [],
                    updates = {
                        "count": 100
                    }
                );
                var response = cbwireController.handleRequest( payload );
                expect( response.components[1].effects.html ).toInclude( "Counter: 100" );
            } );

            it( "can dispatch an event without params", function() {
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
                            "method": "increment",
                            "params": []
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload );
                expect( response.components[1].effects.dispatches ).toBeArray();
                expect( response.components[1].effects.dispatches[1].name ).toBe( "incremented" );
                expect( arrayLen( response.components[1].effects.dispatches[1].params ) ).toBe( 0 );
            } );

            fit( "can dispatch an event with params", function() {
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
                            "method": "incrementBy",
                            "params": [10]
                        }
                    ],
                    updates = {}
                );
                var response = cbwireController.handleRequest( payload );
                expect( response.components[1].effects.dispatches ).toBeArray();
                expect( response.components[1].effects.dispatches[1].name ).toBe( "incrementedBy" );
                expect( arrayLen( response.components[1].effects.dispatches[1].params ) ).toBe( 1 );
            } );
        } );



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
                    name="Counter",
                    params={ "count": 100 },
                    key=""
                );
                expect( html ).toInclude( "Counter: 100" );
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

        response.content.components = response.content.components.map( function( comp ) {
            comp.snapshot = serializeJson( comp.snapshot );
            return comp;
        } );

        response.content = serializeJson( response.content );

        return response;
    }
}
