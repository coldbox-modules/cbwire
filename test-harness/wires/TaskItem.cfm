<cfoutput>
    <div class="card">
        <div class="card-body">
            <div class="d-flex justify-content-between">
                <div>#task#</div>
                <button wire:click="deleteTask( '#task#')" class="btn btn-primary">Delete</button>
            </div>
        </div>
    </div>
</cfoutput>