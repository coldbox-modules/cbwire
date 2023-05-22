<cfoutput>
    <div>
        <form wire:submit.prevent="save">
            <input wire:model="photo" type="file">
            <div>
                <button type="submit" class="btn btn-primary mt-4">Save</button>
            </div>
        </form>
        <div>
            <div wire:loading wire:target="photo">Uploading...</div>
        </div>
        <div>
            <cfif isObject( args.photo )>
                <cfif args.photo.isImage()>
                    <img src="#args.photo.getPreviewURL()#" style="width: 300px; height: auto;">
                <cfelse>
                    <div>The file you uploaded is not an image. Preview not available.</div>
                </cfif>
            </cfif>
        </div>
        <div>
        </div>
    </div>
</cfoutput>