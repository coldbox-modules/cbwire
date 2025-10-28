component extends="coldbox.system.testing.BaseTestCase" {

    function beforeAll() {
        super.beforeAll();
        // delete any files in models/tmp folder (for single-file components)
        local.tempFolder = expandPath( "/cbwire/models/tmp" );
        if ( directoryExists( local.tempFolder ) ) {
            directoryDelete( local.tempFolder, true );
        }
        directoryCreate( local.tempFolder );
    }

    function run(testResults, testBox) {

		describe("onSecure and cbSecurity", function() {

			describe("onMount - onSecure Method Testing", function() {

				beforeEach( function( currentSpec ) {
					// Assuming setup() initializes application environment
					// and prepareMock() is a custom method to mock any dependencies, if necessary.
					setup();
					cbwireController = getInstance("CBWIREController@cbwire");
					event = getRequestContext();
					prepareMock( cbwireController );
				});

				it( "should allow rendering of wire using onSecure method", function () {
					// set private value for this test wire to block rendering via onSecure method
					event.setValue( 'allowTestWireRender', true, true );
					var result = CBWIREController.wire( "test.security.onrender_block_from_prc" );
					expect( result ).toInclude( "<h1>A CBWire Secure Component</h1>" );
				} );

				it( "should block rendering of wire using onSecure method", function () {
					// set private value for this test wire to block rendering via onSecure method
					event.setValue( 'allowTestWireRender', false, true );
					var result = CBWIREController.wire( "test.security.onrender_block_from_prc" );
					expect( result ).notToInclude( "<h1>A CBWire Secure Component</h1>" );
					expect( len( trim( result ) ) ).toBe( 0 );
				} );

				it( "should block rendering of wire using onSecure method with message from cbwire settings", function () {
					var settings = getInstance( "coldbox:modulesettings:cbwire" );
					settings[ "secureMountFailMessage" ] = "<div>MESSSAGE FROM CBWIRE SETTINGS</div>";
					// set private value for this test wire to block rendering via onSecure method
					event.setValue( 'allowTestWireRender', false, true );
					var result = CBWIREController.wire( "test.security.onrender_block_from_prc" );
					expect( result ).toInclude( "<div>MESSSAGE FROM CBWIRE SETTINGS</div>" );
					// remove the custom setting after test
					settings.delete( "secureMountFailMessage" );
				} );

				it( "should block rendering of wire using onSecure method with custom message from wire variable", function () {
					// set private value for this test wire to block rendering via onSecure method
					event.setValue( 'allowTestWireRender', false, true );
					var result = CBWIREController.wire( "test.security.onrender_custom_block_message_from_wire" );
					expect( result ).toInclude( "<div>BLOCK MESSSAGE FROM COMPONENT VARIABLE</div>" );
				} );

				it( "should block rendering of wire using onSecure method with custom message from params overriding the wire variable", function () {
					// set private value for this test wire to block rendering via onSecure method
					event.setValue( 'allowTestWireRender', false, true );
					var result = CBWIREController.wire(
						"test.security.onrender_custom_block_message_from_wire",
						{ "secureMountFailMessage" : "<div>BLOCK MESSSAGE FROM PARAMS</div>" }
					);
					expect( result ).toInclude( "<div>BLOCK MESSSAGE FROM PARAMS</div>" );
				} );

			} );

			describe("incomingRequest - onSecure Method Testing", function() {

				beforeEach( function( currentSpec ) {
					// Assuming setup() initializes application environment
					// and prepareMock() is a custom method to mock any dependencies, if necessary.
					setup();
					cbwireController = getInstance("CBWIREController@cbwire");
					event = getRequestContext();
					prepareMock( cbwireController );
				});

				it( "should always block rendering using onSecure() method that always returns false", () => {
					var payload = incomingRequest(
						memo = {
							"name": "test.security.onsecure_block_always",
							"id": "Z1Ruz1tGMPXSfw7osBW2",
							"children": []
						},
						data = {
							"keyOne": "valueOne"
						},
						calls = [
							{ path: "", method: "updateDataKeyOne", params: [] }
						],
						updates = {}
					);
					var result = cbwireController.handleRequest( payload, event );
					expect( result.components.first().effects.html ).notToInclude( "<p>This wire should never render.</p>" );
					expect( len( trim( result.components.first().effects.html ) ) ).toBe( 0 );
				} );

			} );

			describe("onMount - cbSecurity annotation Testing", function() {

				beforeEach( function( currentSpec ) {
					// Assuming setup() initializes application environment
					// and prepareMock() is a custom method to mock any dependencies, if necessary.
					setup();
					cbSecurity = getInstance( "@cbSecurity" );
					// run logout to ensure no user is logged in
					cbSecurity.logout();
					cbwireController = getInstance("CBWIREController@cbwire");
					event = getRequestContext();
					prepareMock( cbwireController );
				});

				it( "should block rendering of wire using annotation secure when not logged in", function () {
					// run logout to ensure no user is logged in
					cbSecurity.logout();
					var result = CBWIREController.wire( "test.security.cbSecurity_secured_annotation" );
					expect( result ).notToInclude( "<p>Wire Template: cbSecurity_secured_annotation.cfm</p>" );
					expect( len( trim( result ) ) ).toBe( 0 );
				} );

				it( "should allow rendering of wire using annotation secure when logged in", function () {
					cbSecurity.authenticate( "admin", "admin123" );
					var result = CBWIREController.wire( "test.security.cbSecurity_secured_annotation" );
					expect( result ).toInclude( "<p>Wire Template: cbSecurity_secured_annotation.cfm</p>" );
				} );

				it( "should allow rendering of wire using annotation secure='false' when logged out", function () {
					var result = CBWIREController.wire( "test.security.cbSecurity_secured_annotation_eq_false" );
					expect( result ).toInclude( "<p>Wire Template: cbSecurity_secured_annotation_eq_false.cfm</p>" );
				} );

				it( "should block rendering of wire using annotation secure='write' permission when logged out", function () {
					var result = CBWIREController.wire( "test.security.cbSecurity_secured_annotation_single_permission" );
					expect( result ).notToInclude( "<p>Wire Template: cbSecurity_secured_annotation_single_permission.cfm</p>" );
					expect( len( trim( result ) ) ).toBe( 0 );
				} );

				it( "should allow rendering of wire using annotation secure='write' permission when logged in with permission", function () {
					cbSecurity.authenticate( "admin", "admin123" );
					var result = CBWIREController.wire( "test.security.cbSecurity_secured_annotation_single_permission" );
					expect( result ).toInclude( "<p>Wire Template: cbSecurity_secured_annotation_single_permission.cfm</p>" );
					expect( len( trim( result ) ) ).notToBe( 0 );
				} );

				it( "should block rendering of wire using annotation secure='write' permission when logged in without permission", function () {
					cbSecurity.authenticate( "user", "user123" );
					var result = CBWIREController.wire( "test.security.cbSecurity_secured_annotation_single_permission" );
					expect( result ).notToInclude( "<p>Wire Template: cbSecurity_secured_annotation_single_permission.cfm</p>" );
					expect( len( trim( result ) ) ).toBe( 0 );
				} );

				it( "should allow rendering of wire using annotation secure='write,delete' permission (multiple) when logged in with permission", function () {
					cbSecurity.authenticate( "admin", "admin123" );
					var result = CBWIREController.wire( "test.security.cbSecurity_secured_annotation_multiple_permission" );
					expect( result ).toInclude( "<p>Wire Template: cbSecurity_secured_annotation_multiple_permission.cfm</p>" );
					expect( len( trim( result ) ) ).notToBe( 0 );
				} );

				it( "should block rendering of wire using annotation secure='write,delete' permission (multiple) when logged in without permission", function () {
					cbSecurity.authenticate( "user", "user123" );
					var result = CBWIREController.wire( "test.security.cbSecurity_secured_annotation_multiple_permission" );
					expect( result ).notToInclude( "<p>Wire Template: cbSecurity_secured_annotation_multiple_permission.cfm</p>" );
					expect( len( trim( result ) ) ).toBe( 0 );
				} );

			} );

			describe("incomingRequest - cbSecurity method annotation Testing", function() {

				beforeEach( function( currentSpec ) {
					// Assuming setup() initializes application environment
					// and prepareMock() is a custom method to mock any dependencies, if necessary.
					setup();
					cbSecurity = getInstance( "@cbSecurity" );
					// run logout to ensure no user is logged in
					cbSecurity.logout();
					cbwireController = getInstance("CBWIREController@cbwire");
					event = getRequestContext();
					prepareMock( cbwireController );
				});

				it( "should block secured wire component when not logged in", () => {
					var payload = incomingRequest(
						memo = {
							"name": "test.security.cbSecurity_secured_annotation",
							"id": "Z1Ruz1tGMPXSfw7osBW2",
							"children": []
						},
						data = {
							"keyOne": "valueOne",
							"keyTwo": "valueTwo"
						},
						calls = [],
						updates = {}
					);
					var result = cbwireController.handleRequest( payload, event );
					expect( result.components.first().effects.html ).notToInclude( "<p>Wire Template: cbSecurity_secured_annotation.cfm</p>" );
					expect( len( trim( result.components.first().effects.html ) ) ).toBe( 0 );
				} );

				it( "should invoke un-secured method updateDataKeyOne() and NOT invoke secured method updateDataKeyTwo()", () => {
					var payload = incomingRequest(
						memo = {
							"name": "test.security.cbSecurity_method_secured_annotation",
							"id": "Z1Ruz1tGMPXSfw7osBW2",
							"children": []
						},
						data = {
							"keyOne": "valueOne",
							"keyTwo": "valueTwo"
						},
						calls = [
							{ path: "", method: "updateDataKeyOne", params: [] },
							{ path: "", method: "updateDataKeyTwo", params: [] }
						],
						updates = {}
					);
					var result = cbwireController.handleRequest( payload, event );
					// updateDataKeyOne() is NOT secured so it should update
					expect( result.components.first().effects.html ).toInclude( "<p>KeyOne:updatedValueOne</p>" );
					// updateDataKeyTwo() is secured so it should NOT update
					expect( result.components.first().effects.html ).notToInclude( "<p>KeyTwo:updatedValueTwo</p>" );
					expect( result.components.first().effects.html ).toInclude( "<p>KeyTwo:valueTwo</p>" );
				} );

				it( "should invoke both updateDataKeyOne() and updateDataKeyTwo() when logged in", () => {
					cbSecurity.authenticate( "admin", "admin123" );
					var payload = incomingRequest(
						memo = {
							"name": "test.security.cbSecurity_method_secured_annotation",
							"id": "Z1Ruz1tGMPXSfw7osBW2",
							"children": []
						},
						data = {
							"keyOne": "valueOne",
							"keyTwo": "valueTwo"
						},
						calls = [
							{ path: "", method: "updateDataKeyOne", params: [] },
							{ path: "", method: "updateDataKeyTwo", params: [] }
						],
						updates = {}
					);
					var result = cbwireController.handleRequest( payload, event );
					// updateDataKeyOne() is NOT secured so it should update
					expect( result.components.first().effects.html ).toInclude( "<p>KeyOne:updatedValueOne</p>" );
					expect( result.components.first().effects.html ).notToInclude( "<p>KeyOne:valueOne</p>" );
					// updateDataKeyTwo() is secured so it should NOT update
					expect( result.components.first().effects.html ).toInclude( "<p>KeyTwo:updatedValueTwo</p>" );
					expect( result.components.first().effects.html ).notToInclude( "<p>KeyTwo:valueTwo</p>" );
				} );

				it("should allow render, invoke secured methods except updateDataKeyFour()", () => {
					cbSecurity.authenticate( "admin", "admin123" );
					var payload = incomingRequest(
						memo = {
							"name": "test.security.cbSecurity_secured_annotation",
							"id": "Z1Ruz1tGMPXSfw7osBW2",
							"children": []
						},
						data = {
							"keyOne": "valueOne",
							"keyTwo": "valueTwo",
							"keyThree": "valueThree",
							"keyFour": "valueFour"
						},
						calls = [
							{ path: "", method: "updateDataKeyOne", params: [] },
							{ path: "", method: "updateDataKeyTwo", params: [] },
							{ path: "", method: "updateDataKeyThree", params: [] },
							{ path: "", method: "updateDataKeyFour", params: [] }
						],
						updates = {}
					);
					var result = cbwireController.handleRequest( payload, event );
					expect( result.components.first().effects.html ).toInclude( "<p>KeyOne:updatedValueOne</p>" );
					expect( result.components.first().effects.html ).toInclude( "<p>keyTwo:updatedValueTwo</p>" );
					expect( result.components.first().effects.html ).toInclude( "<p>keyThree:updatedValueThree</p>" );
					expect( result.components.first().effects.html ).toInclude( "<p>keyFour:valueFour</p>" );

					expect( result.components.first().effects.html ).notToInclude( "<p>keyFour:updatedValueTwo</p>" );
				} );

				it("should allow render, invoke secured methods except updateDataKeyTwo() and updateDataKeyFour() based on user permissions", () => {
					cbSecurity.authenticate( "user", "user123" );
					var payload = incomingRequest(
						memo = {
							"name": "test.security.cbSecurity_secured_annotation",
							"id": "Z1Ruz1tGMPXSfw7osBW2",
							"children": []
						},
						data = {
							"keyOne": "valueOne",
							"keyTwo": "valueTwo",
							"keyThree": "valueThree",
							"keyFour": "valueFour"
						},
						calls = [
							{ path: "", method: "updateDataKeyOne", params: [] },
							{ path: "", method: "updateDataKeyTwo", params: [] },
							{ path: "", method: "updateDataKeyThree", params: [] },
							{ path: "", method: "updateDataKeyFour", params: [] }
						],
						updates = {}
					);
					var result = cbwireController.handleRequest( payload, event );
					// what we expect
					expect( result.components.first().effects.html ).toInclude( "<p>KeyOne:updatedValueOne</p>" );
					expect( result.components.first().effects.html ).toInclude( "<p>keyTwo:valueTwo</p>" );
					expect( result.components.first().effects.html ).toInclude( "<p>keyThree:updatedValueThree</p>" );
					expect( result.components.first().effects.html ).toInclude( "<p>keyFour:valueFour</p>" );
					// what we do NOT expect
					expect( result.components.first().effects.html ).notToInclude( "<p>keyFour:updatedValueTwo</p>" );
					expect( result.components.first().effects.html ).notToInclude( "<p>keyTwo:updatedValueTwo</p>" );
				} );

			} );
    	} );

	};

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
        updates = {},
        csrfToken = ""
    ){

        var response = {
            "content": {
                "_token": arguments.csrfToken.len() ? arguments.csrfToken : getInstance( "CBWIREController@cbwire" ).generateCSRFToken(),
                "components": [
                    {
                        "calls": arguments.calls,
                        "snapshot": {
                            "data": arguments.data,
                            "memo": arguments.memo,
                            "checksum": ""
                        },
                        "updates": arguments.updates
                    }
                ]
            }
        };

        response.content.components = response.content.components.map( function( _comp ) {
            _comp.snapshot = getInstance( "ChecksumService@cbwire" ).calculateChecksum( _comp.snapshot );
            return _comp;
        } );

        response.content = serializeJson( response.content );

        return response;
    }

    /**
     * Take a rendered HTML component and breaks out its snapshot,
     * effects, etc for analysis during tests.
     *
     * @return struct
     */
    private function parseRendering( html, index = 1 ) {
        local.result = {};
        // Determine outer element
        local.outerElementMatches = reMatchNoCase( "<([a-z]+)\s*", html );
        local.result[ "outerElement" ] = reFindNoCase( "<([a-z]+)\s*", html, 1, true ).match[ 2 ];
        // Parse snapshot
        local.result[ "snapshot" ] = parseSnapshot( html, index );
        // Parse effects
        local.result[ "effects" ] = parseEffects( html, index );
        return local.result;
    }

    /**
     * Parse the snapshot from a rendered HTML component by decoding
     * ALL HTML entities before attempting JSON deserialization.
     *
     * @html string | The rendered HTML containing the component.
     * @index numeric | The index of the component if multiple match (usually 1).
     *
     * @return struct The deserialized snapshot struct.
     *
     * @throws Error if parsing or deserialization fails.
     */
    private function parseSnapshot( required string html, numeric index = 1 ) {
        // Use single quotes for regex literals to avoid excessive escaping
        local.match = reMatchNoCase( 'wire:snapshot="([^"]+)"', arguments.html );
        if ( !arrayLen( local.match ) >= arguments.index ) {
            throw( message="Snapshot attribute not found at index #arguments.index# in provided HTML.", detail=arguments.html );
        }
        local.snapshotAttributeMatch = local.match[ arguments.index ];

        // Extract the encoded value
        local.regexMatches = reFindNoCase( 'wire:snapshot="([^"]+)"', local.snapshotAttributeMatch, 1, true );
        if ( !arrayLen( local.regexMatches.match ) == 2 ) {
             throw( message="Could not extract snapshot value using regex from attribute match.", detail=local.snapshotAttributeMatch );
        }
        local.snapshotEncoded = local.regexMatches.match[ 2 ];

        // Decode ALL HTML entities (handles ", ", ", <, &, etc.)
        local.snapshotDecoded = canonicalize( local.snapshotEncoded, true, true ); // Key change!

        try {
             return deserializeJSON( local.snapshotDecoded );
        } catch ( any e ) {
            // Provide more context on failure for easier debugging
            var errorMsg = "Failed to deserialize snapshot JSON after decoding HTML entities.";
            errorMsg &= " Decoded JSON string was: [#encodeForHtml(local.snapshotDecoded)#]."; // Encode for safe display
            errorMsg &= " Original Error: #e.message# #e.detail#";
            throw( message=errorMsg, detail=local.snapshotDecoded );
        }
    }

    /**
     * Parse the effects from a rendered HTML component by decoding
     * ALL HTML entities before attempting JSON deserialization.
     *
     * @html The rendered HTML containing the component.
     * @index The index of the component if multiple match (usually 1).
     *
     * @return any The deserialized effects (usually struct or array).
     *
     * @throws Error if parsing or deserialization fails.
     */
    private function parseEffects( required string html, numeric index = 1 ) {
        // Use single quotes for regex literals
        local.match = reMatchNoCase( 'wire:effects="([^"]+)"', arguments.html );
         if ( !arrayLen( local.match ) >= arguments.index ) {
            throw( message="Effects attribute not found at index #arguments.index# in provided HTML.", detail=arguments.html );
        }
        local.effectsAttributeMatch = local.match[ arguments.index ];

        // Extract the encoded value
        local.regexMatches = reFindNoCase( 'wire:effects="([^"]+)"', local.effectsAttributeMatch, 1, true );
        if ( !arrayLen( local.regexMatches.match ) == 2 ) {
             throw( message="Could not extract effects value using regex from attribute match.", detail=local.effectsAttributeMatch );
        }
        local.effectsEncoded = local.regexMatches.match[ 2 ];

        // Decode ALL HTML entities
        local.effectsDecoded = canonicalize( local.effectsEncoded, true, true ); // Key change!

         try {
            if ( isJSON( local.effectsDecoded ) ) {
                return deserializeJSON( local.effectsDecoded );
            } else {
                return {};
            }
        } catch ( any e ) {
             // Provide more context on failure
            var errorMsg = "Failed to deserialize effects JSON after decoding HTML entities.";
            errorMsg &= " Decoded JSON string was: [#encodeForHtml(local.effectsDecoded)#]."; // Encode for safe display
            errorMsg &= " Original Error: #e.message# #e.detail#";
            throw( message=errorMsg, detail=local.effectsDecoded );
        }
    }

    /**
     * Check if the current environment is a BoxLang environment
     *
     * @return boolean
     */
    private function isBoxLang() {
        return server.keyExists( "boxlang" );
    }

}
