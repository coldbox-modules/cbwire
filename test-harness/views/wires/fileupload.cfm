<cfoutput>
    <div>
        <form wire:submit.prevent="save">
            <input wire:model="myFile" type="file">
            <div>
                <button type="submit" class="btn btn-primary mt-4">Save</button>
            </div>
        </form>
        <div>
            <div wire:loading wire:target="myFile">Uploading...</div>
        </div>
        <div>
            <cfif isObject( args.myFile )>
                <cfif args.myFile.isImage()>
                    <img src="#args.myFile.getPreviewURL()#" style="width: 300px; height: auto;">
                <cfelse>
                    <div>The file you uploaded is not an image. Preview not available.</div>
                </cfif>
                <h2>Meta Information</h2>
                <cfdump var="#args.myFile.getMeta()#">
            </cfif>
        </div>
        <div>
        </div>
    </div>
</cfoutput>