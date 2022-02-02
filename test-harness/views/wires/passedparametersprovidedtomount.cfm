<cfoutput>
    <div>
        Pizza Toppings:
        <ul>
            <cfloop array="#args.pizzaToppings#" index="topping">
                <li>#topping#</li>
            </cfloop>
        </ul>
    </div>
</cfoutput>