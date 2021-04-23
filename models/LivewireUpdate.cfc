component {

    function init( required struct update ) {
        variables.update = update;
    }

    function getType() {
        return update.type;
    }

    function isType( checkType ) {
        return checkType == getType();
    }

    function hasPayload() {
        return structKeyExists( update, "payload" );
    }

    function getPayload() {
        return update[ "payload" ];
    }

    function hasPayloadMethod() {
        return hasPayload() && structKeyExists( getPayload(), "method" );
    }

    function getPayloadMethod() {
        return getPayload()[ "method" ];
    }

    function hasPassedParams() {
        return hasPayload() && structKeyExists( getPayload(), "params" ) && isArray( getPayload()[ "params" ] );
    }

    function getPassedParams() {
        return getPayload()[ "params" ];
    }

    function getPassedParamsAsArguments() {
        if ( hasPassedParams() ) {
            return getPassedParams().reduce( function( agg, param, index ) {
                agg[ index ] = param;
                return agg;
            }, {} );
        }
        return {};
    }

    function hasCallableMethod( required Component livewireComponent ) {
        return hasPayloadMethod() && livewireComponent.hasMethod( getPayloadMethod() );
    }

}