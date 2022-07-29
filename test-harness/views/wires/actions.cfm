<cfoutput>
    <div>
        <div>#args.result#</div>
        <div class="mt-4">
            <button wire:click="action1" type="button" class="btn btn-primary">Action ##1</button>
            <button wire:click="action2" type="button" class="btn btn-primary ms-4">Action ##2</button>
            <button wire:click="action3( 'Action ##3' )" type="button" class="btn btn-primary ms-4">Action ##3</button>
        </div>
    </div>
</cfoutput>