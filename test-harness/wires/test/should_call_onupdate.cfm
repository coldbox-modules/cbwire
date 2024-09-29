<cfoutput>
    <div>
        <h1>Should Call OnUpdate</h1>
        <p>
            onUpdateCalled: #onUpdateCalled#
        </p>
    </div>
</cfoutput>

<cfscript>
    // @startWire 
    data = {
        "onUpdateCalled": false
    };

    function onUpdate( newValues, oldValues ){
        data.onUpdateCalled = true;
    }
    // @endWire
</cfscript>