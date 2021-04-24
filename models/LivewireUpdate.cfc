component {

    function init( required struct update ) {
        variables.update = update;
    }

    function getType() {
        return variables.update.type;
    }

    function isType( checkType ) {
        return checkType == this.getType();
    }

    function hasPayload() {
        return structKeyExists( variables.update, "payload" );
    }

    function getPayload() {
        return variables.update[ "payload" ];
    }

    function hasPayloadMethod() {
        return this.hasPayload() && structKeyExists( this.getPayload(), "method" );
    }

    function getPayloadMethod() {
        return this.getPayload()[ "method" ];
    }

    function hasPassedParams() {
        return this.hasPayload() && structKeyExists( this.getPayload(), "params" ) && isArray( this.getPayload()[ "params" ] );
    }

    function getPassedParams() {
        return this.getPayload()[ "params" ];
    }

    function getPassedParamsAsArguments() {
        if ( this.hasPassedParams() ) {
            return this.getPassedParams().reduce( function( agg, param, index ) {
                agg[ index ] = param;
                return agg;
            }, {} );
        }
        return {};
    }

    function hasCallableMethod( required Component livewireComponent ) {
        return this.hasPayloadMethod() && livewireComponent.hasMethod( getPayloadMethod() );
    }

}