component extends="coldbox.system.testing.BaseTestCase" {

    // Lifecycle methods and BDD suites as before...

    function run(testResults, testBox) {
        describe("Component.cfc", function() {

            beforeEach(function(currentSpec) {
                // Assuming setup() initializes application environment
                // and prepareMock() is a custom method to mock any dependencies, if necessary.
                setup();
                comp = getInstance("wires.SuperHeroes");
                comp._withEvent( getRequestContext( ) );
                prepareMock( comp );
            });

            it("is an object", function() {
                expect(isObject(comp)).toBeTrue();
            });

            it("has generated getter", function() {
                expect(comp.getHeroes()).toBeArray();
            });

            it("has generated setter", function() {
                comp.setHeroes( [ "iron man", "superman" ] );
                expect(comp.getHeroes().len()).toBe(2);
            });

            it( "can call getInstance()", function() {
                var result = comp.getInstance( "wires.SuperHeroes" );
                expect( result ).toBeInstanceOf( "SuperHeroes" );
            } );

            it("can call action", function() {
                comp.setVillians( [ "joker", "lex luthor" ] );
                comp.defeatVillians();
                expect(comp.getVillians().len()).toBe(0);
            });

            it("renders with correct snapshot, effects, and id attribute", function() {
                var renderedHtml = comp.renderIt();
                expect(renderedHtml.contains('<div wire:snapshot="{')).toBeTrue();
                expect(renderedHtml.contains('wire:effects="[]')).toBeTrue();
                expect(renderedHtml.contains('id="')).toBeTrue();
            });

            it("renders string booleans as booleans", function() {
                var renderedHtml = comp.renderIt();
                expect(renderedHTML.contains('isMarvel&quot;:true') ).toBeTrue();
            });

            it("can render a view template", function() {
                comp.addHero("Iron Man");
                var viewContent = comp.view("wires.superheroes");
                expect(viewContent).toInclude("Super Heroes");
                expect(viewContent).toInclude("Iron Man");
            });

            it("can implicitly render a view template", function() {
                comp = getInstance("wires.ImplicitRender");
                var viewContent = comp.renderIt();
                expect(viewContent).toInclude("I rendered implicitly");
            });

            it("can pass additional data to the view", function() {
                var viewContent = comp.view("wires.SuperHeroes", { heroes: [ "Wonder Woman"] });
                expect(viewContent).toInclude("Wonder Woman");
            });

            it( "supports computed properties", function() {
                expect( comp.numberOfHeroes() ).toBe( 0 );
            } );

            it( "computed properties are cached", function() {
                var strength1 = comp.calculateStrength();
                sleep( 10 );
                var strength2 = comp.calculateStrength();
                expect( strength1 ).toBe( strength2 );
            } );

            it( "computed properties can accept false flag to prevent caching", function() {
                var strength1 = comp.calculateStrength();
                sleep( 10 );
                var strength2 = comp.calculateStrength( false );
                expect( strength1 ).notToBe( strength2 );
            } );

            it( "returns a snapshot that contains the proper memo name", function() {
                var snapshot = comp._getSnapshot();
                expect( snapshot.memo.name ).toBe( "SuperHeroes" );
                expect( snapshot.memo.path ).toBe( "SuperHeroes" );
            } );

            it( "computed property can be accessed from view", function() {
                comp.addHero( "Iron Man" );
                comp.addHero( "Superman" );
                var viewContent = comp.view("wires.superheroes" );
                expect(viewContent).toInclude("Number Of Heroes: 2");
            } );

            it( "data properties can be accessed from view using args.", function() {
                comp.addHero( "Iron Man" );
                comp.addHero( "Superman" );
                var viewContent = comp.view("wires.superheroesusingargs" );
                expect(viewContent).toInclude("Number Of Heroes: 2");
            } );

            it( "throws error if we try to set a dataproperty that doesn't exist", function() {
                expect(function() {
                    comp.setCount( 1000 );
                }).toThrow( type="CBWIREException" );
            } );

            it( "can reset all data properties", function() {
                comp.addHero( "Captain America" );
                comp.reset();
                expect( comp.numberOfHeroes() ).toBe( 0 );
            } );

            it( "can reset a single data property", function() {
                comp.addHero( "Thor" );
                comp.addVillian( "Loki" );
                comp.reset( "heroes" );
                expect( comp.numberOfHeroes() ).toBe( 0 );
                expect( comp.numberOfVillians() ).toBe( 1 );
            } );

            it( "can reset multiple data properties", function() {
                comp.addHero( "Thor" );
                comp.addVillian( "Loki" );
                comp.reset( [ "heroes", "villians" ] );
                expect( comp.numberOfHeroes() ).toBe( 0 );
                expect( comp.numberOfVillians() ).toBe( 0 );
            } );

            it( "can resetExcept a single data property", function() {
                comp.addHero( "Thor" );
                comp.addVillian( "Loki" );
                comp.resetExcept( "heroes" );
                expect( comp.numberOfHeroes() ).toBe( 1 );
                expect( comp.numberOfVillians() ).toBe( 0 );
            } );

            it( "can resetExcept multiple data properties", function() {
                comp.addHero( "Thor" );
                comp.addVillian( "Loki" );
                comp.resetExcept( [ "heroes" ] );
                expect( comp.numberOfHeroes() ).toBe( 1 );
                expect( comp.numberOfVillians() ).toBe( 0 );
            } );

            it( "can render child components", function() {
                comp.setShowStats( true );
                var result = comp.view( "wires.superheroes" );
                expect( result ).toInclude( "&quot;super-hero" );
            } );

            it( "provide teleport and endTeleport methods", function() {
                expect( comp.teleport( 'body' ) ).toBe( "<template x-teleport=""body"">" );
                expect( comp.endTeleport() ).toBe( "</template>" );
            } );

            it( "can validate()", function() {
                var result = comp.validate();
                expect( result ).toBeInstanceOf( "ValidationResult" );
                expect( result.hasErrors() ).toBeTrue();
            } );

            it("can access validation from view", function() {
                var result = comp.validate();
                var viewContent = comp.view("wires.superheroesvalidation");
                expect(viewContent).toInclude("The 'mailingList' has an invalid type, expected type is email");
            });

            it( "auto validates", function() {
                var viewContent = comp.view("wires.superheroesvalidation");
                expect(viewContent).toInclude("The 'mailingList' has an invalid type, expected type is email");
            } );

            it( "can validateOrFail", function() {
                expect(function() {
                    comp.validateOrFail();
                }).toThrow( type="ValidationException" );

                comp.setMailingList( "x-men@somedomain.com" );
                expect( comp.validateOrFail() ).toBeInstanceOf( "ValidationResult" );
            } );

            it( "can hasError( field)", function() {
                comp.validate();
                expect( comp.hasErrors( "mailingList" ) ).toBeTrue();
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
