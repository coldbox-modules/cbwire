<cfoutput>
<div>
    <button wire:click="sayHello( $event.target.innerText, 'Goodbye' )">Say Hello To Waldo</button>
    #args.message#
</div>
</cfoutput>