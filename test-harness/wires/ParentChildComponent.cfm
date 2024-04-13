<cfscript>
    data = {
        "name": "Grant",
        "toggle": true
    };

    function toggleComps() {
        data.toggle = !data.toggle;
    }

    function reload() {
        refresh();
    }
</cfscript>

<cfoutput>
    <div>
        <h1>Parent</h1>
        <div>Rendered at #now()#</div>
        <div>#name#</div>
        <button wire:click="reload">reload</button>
        <button wire:click="$refresh">$refresh</button>
        <button wire:click="toggleComps">toggle</button>
        <button wire:click="$set( 'name', 'Elsie')">change name</button>

        <cfif toggle>
            #wire( "ChildComponent", {}, "some_id" )#
        <cfelse>
            #wire( "DataBinding" )#
        </cfif>
    </div>
</cfoutput>