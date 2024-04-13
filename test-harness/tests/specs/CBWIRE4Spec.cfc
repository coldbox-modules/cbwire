component extends="coldbox.system.testing.BaseTestCase" {

    // Lifecycle methods and BDD suites as before...

    function run(testResults, testBox) {
        describe("Counter.cfc", function() {

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

            it("initial count is 1", function() {
                expect(comp.getCount()).toBe(1);
            });

            it("increments count", function() {
                comp.increment();
                expect(comp.getCount()).toBe(2);
            });

            it("decrements count", function() {
                comp.decrement();
                expect(comp.getCount()).toBe(0);
            });

            it("renders with correct snapshot, effects, and id attribute", function() {
                comp.$("_renderViewContent", "<div>test</div>" );
                var renderedHtml = comp.renderIt();
                expect(renderedHtml.contains('wire:snapshot="{')).toBeTrue();
                expect(renderedHtml.contains('wire:effects="[]')).toBeTrue();
                expect(renderedHtml.contains('id="')).toBeTrue();
            });

            it("can render a view template", function() {
                var viewContent = comp.view("wires.Counter"); // Adjust based on your view's location
                expect(viewContent).toInclude("Counter: 1");
            });

            it("can pass additional data to the view", function() {
                var viewContent = comp.view("wires.Counter", { count: 5 });
                expect(viewContent).toInclude("Counter: 5");
            });

            it("can access properties using 'data' dot for backwards compatability", function() {
                var viewContent = comp.view("wires.CounterUsingDataDot" );
                expect(viewContent).toInclude("Counter: 1");
            });

            it("decrements count using 'data' dot", function() {
                comp.decrementWithDataDot();
                expect(comp.getCount()).toBe(0);
            });

            it("can access properties using 'args' dot for backwards compatability", function() {
                var viewContent = comp.view("wires.CounterUsingArgsDot" );
                expect(viewContent).toInclude("Counter: 1");
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

            it( "computed property can be accessed from view", function() {
                var viewContent = comp.view("wires.CounterUsingComputedProperty" );
                expect(viewContent).toInclude("Counter: 11");
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

        describe( "CounterUsingCBWIRE3.cfc", function() {

            beforeEach(function(currentSpec) {
                // Assuming setup() initializes application environment
                // and prepareMock() is a custom method to mock any dependencies, if necessary.
                setup();
                comp = getInstance("wires.CounterUsingCBWIRE3");
                prepareMock( comp );
            });

            it("is an object", function() {
                expect(isObject(comp)).toBeTrue();
            });

            it("initial count is 1", function() {
                expect(comp.getData().count).toBe(1);
            });

            it("increments count", function() {
                comp.increment();
                expect(comp.getData().count).toBe(2);
            });

            it("decrements count", function() {
                comp.decrement();
                expect(comp.getData().count).toBe(0);
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

        } );

        describe("CBWIREController", function() {

            beforeEach(function(currentSpec) {
                // Assuming setup() initializes application environment
                // and prepareMock() is a custom method to mock any dependencies, if necessary.
                setup();
                cbwireController = getInstance("CBWIREController@cbwire");
                prepareMock( cbwireController );
            });

            it( "wire calls onMount", function() {
                var result = cbwireController.createInstance( "Counter" );
                expect( result ).toInclude( "Counter: 10" );
            } );

            
        });
    }
}
