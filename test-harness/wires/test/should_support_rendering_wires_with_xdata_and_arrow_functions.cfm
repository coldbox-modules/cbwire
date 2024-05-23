<cfscript>
    // @startWire

    // @endWire
</cfscript>

<cfoutput>
    <div x-data="{
        show: true,
        previous() {
            $wire.previous().then( () => {
                this.show = false;
            })
        }
    }">
        Component
    </div>
</cfoutput>