component accessors="true" {

    // Inject module settings
    property name="moduleSettings" inject="coldbox:modulesettings:cbwire";

    /**
     * Calculates a checksum for the component's payload, inserts the checksum into the payload,
     * and returns the updated payload as a JSON string.
     *
     * @payload struct | the payload to calculate the checksum for
     *
     * @return string
     */
    function calculateChecksum( snapshot ) {
        // Create a copy to avoid modifying the original during calculation
        var snapshotCopy = duplicate( snapshot );
        
        // Always clear the checksum before calculating a new one
        if ( snapshotCopy.keyExists( "checksum" ) ) {
            snapshotCopy.delete( "checksum" );
        }
        
        var secret = moduleSettings.keyExists("secret") ? moduleSettings.secret : hash( moduleSettings.moduleRootPath );
        
        // Create normalized JSON for checksum calculation
        var normalizedPayload = normalizeForChecksum( snapshotCopy );
       
        // Calculate checksum and add it to the original snapshot
        var calculatedChecksum = hmac( normalizedPayload, secret, "HMACSHA256" );
        snapshot[ "checksum" ] = calculatedChecksum;
        
        return serializeJson( snapshot );
    }

    /**
     * Validates checksum for the component's data from snapshot.
     *
     * @payload string | the JSON string of the component snapshot as posted by livewire
     *
     * @return void
     */
    function validateChecksum( snapshot ) {
        if( !isJson( snapshot ) ) {
            throw( type="CBWIRECorruptPayloadException", message="Payload is not valid JSON." );
        }
        
        var deserializedSnapshot = deserializeJSON( snapshot );

        if( !deserializedSnapshot.keyExists("checksum") ) {
            throw( type="CBWIRECorruptPayloadException", message="Checksum Not Found." );
        }
        
        
        var incomingChecksum = deserializedSnapshot.checksum;
        var secret = moduleSettings.keyExists("secret") ? moduleSettings.secret : hash( moduleSettings.moduleRootPath );
        
        // Create a copy without checksum for validation
        var snapshotForValidation = duplicate( deserializedSnapshot );

        if ( snapshotForValidation.keyExists( "checksum" ) ) {
            snapshotForValidation.delete( "checksum" );
        }
        
        // Calculate what the checksum should be
        var normalizedPayload = normalizeForChecksum( snapshotForValidation );

        var expectedChecksum = hmac( normalizedPayload, secret, "HMACSHA256" );
        
        if( incomingChecksum != expectedChecksum ){
            throw( type="CBWIRECorruptPayloadException", message="Checksum Mismatch. Expected: " & expectedChecksum & ", Got: " & incomingChecksum );
        }
    }

    /**
     * Normalizes a data structure for consistent checksum calculation
     * This ensures the same data always produces the same checksum regardless of key order
     *
     * @data struct | the data to normalize
     *
     * @return string
     */
    private function normalizeForChecksum( data ) {
        // Convert to JSON first
        var jsonString = serializeJson( data );
        
        // Parse it back to ensure consistent formatting
        var parsedData = deserializeJSON( jsonString );
        
        // Sort keys recursively to ensure consistent ordering
        var sortedData = sortKeysRecursively( parsedData );
        
        // Serialize with consistent formatting
        var normalizedJson = serializeJson( sortedData );

        normalizedJson = reReplace( normalizedJson, "\s*", "", "all" );
        
        // Remove all whitespace ( this ensures whitespaceManagement does not effect our checksum )
        return replace( normalizedJson, "\s+", "", "all" );
    }

    /**
     * Recursively sorts all keys in a data structure
     *
     * @data any | the data structure to sort
     *
     * @return any
     */
    private function sortKeysRecursively( data ) {
        // Handle null values first
        if ( isNull( data ) ) {
            return javaCast( "null", "" );
        }
        
        if ( isStruct( data ) ) {
            var sortedStruct = {};
            var keys = structKeyArray( data );
            arraySort( keys, "text", "asc" );
            
            for ( var key in keys ) {
                try {
                    if ( structKeyExists( data, key ) ) {
                        var value = structFind( data, key );
                        if ( isNull( value ) ) {
                            sortedStruct[key] = javaCast( "null", "" );
                        } else if ( isStruct( value ) || isArray( value ) ) {
                            sortedStruct[key] = sortKeysRecursively( value );
                        } else {
                            sortedStruct[key] = value;
                        }
                    } else {
                        sortedStruct[key] = javaCast( "null", "" );
                    }
                } catch ( any e ) {
                    // If we can't access the value safely, skip it or set to null
                    sortedStruct[key] = javaCast( "null", "" );
                }
            }
            return sortedStruct;
        } else if ( isArray( data ) ) {
            var sortedArray = [];
            for ( var i = 1; i <= arrayLen( data ); i++ ) {
                try {
                    var value = data[i];
                    if ( isNull( value ) ) {
                        arrayAppend( sortedArray, javaCast( "null", "" ) );
                    } else {
                        arrayAppend( sortedArray, sortKeysRecursively( value ) );
                    }
                } catch ( any e ) {
                    arrayAppend( sortedArray, javaCast( "null", "" ) );
                }
            }
            return sortedArray;
        } else {
            return data;
        }
    }
}