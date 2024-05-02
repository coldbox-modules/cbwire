<cfoutput>
    <div>
        <h1>Parent</h1>
        <div>Rendered at #now()#</div>
        <div>#name#</div>
        <div>toggle = #toggle#</div>
        <button wire:click="reload">reload</button>
        <button wire:click="$refresh">$refresh</button>
        <button wire:click="toggleComps">toggle</button>
        <button wire:click="$set( 'name', 'Elsie')">change name</button>

        <cfif toggle>
            #wire( "ChildComponent", {}, "some_id" )#
        <cfelse>
            #wire( "DataBinding" )#
        </cfif>

        Counter goes here
        <cbwire:counter
            :count="10"
            anothervalue="test" />
        <cbwire:counter :count="10" :anothervalue="name" />

    </div>
</cfoutput>