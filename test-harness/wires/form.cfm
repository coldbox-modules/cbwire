<cfscript>
    examples = [
        {
            "name": "WireModel",
            "description": "Updates the client-side state when the input value changes, and updates the server when an action is performed.",
            "heading": "wire:model"
        },
        {
            "name": "WireModelLive",
            "description": "Updates the component when an action is called, in this case submit().",
            "heading": "wire:model.live"
        },
        {
            "name": "WireModelBlur",
            "description": "Updates the component when an action is called, in this case submit().",
            "heading": "wire:model.blur"
        }
    ];
</cfscript>

<cfoutput>
    <div>
        <h1>Forms</h1>

        <h2>Text Inputs</h2>

        <hr>
        <cfloop array="#examples#" index="example">
            <h3>#example.heading#</h3>
            <p>#example.description#</p>
            <cftry>
                <cfset snippets = wire( name="ShowCode", params={ "wire": example.name } )>
                <cfset preview = wire( example.name )>
                <div class="row">
                    <div class="col-lg-6">
                        <!--- code snippet --->
                        #snippets#
                    </div>
                    <div class="col-lg-6">
                        <!--- example preview --->
                        <div style="background-color:##333; color: ##fff; min-height: 100%; border-radius: 5px;" class="p-5">
                            #preview#
                        </div>
                    </div>
                </div>
                <hr>
                <cfcatch type="any">
                    #cfcatch.message#
                </cfcatch>
            </cftry>
        </cfloop>
    </div>
</cfoutput>