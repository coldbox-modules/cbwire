<cfoutput>
    <div wire:poll>
        Current timestamp: #args.timestamp#
    </div>
</cfoutput>

<!---
0: {type: "callMethod", payload: {method: "blah", params: []}}
--->

<!---
    updates: [{type: "callMethod", payload: {method: "$refresh", params: []}}]
--->