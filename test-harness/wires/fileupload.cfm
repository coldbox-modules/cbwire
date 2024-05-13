<cfoutput>
    <div>
        <form wire:submit.prevent="save">
            <input wire:model="photo" type="file">
            <input wire:model="photos" type="file" multiple>

            <div>
                <button type="submit" class="btn btn-primary mt-4">Save</button>
                <button type="button" wire:click="update">Update</button>
            </div>
        </form>
        <div>
            <div wire:loading wire:target="photo">Uploading...</div>
        </div>
        #now()#
        <div>
            <cfif isObject( photo )>
                <cfif photo.isImage()>
                    <img src="#photo.getPreviewURL()#" style="width: 300px; height: auto;">
                <cfelse>
                    <div>The file you uploaded is not an image. Preview not available.</div>
                </cfif>
            </cfif>

            <cfif isArray( photos )>
                <div>
                    <cfloop array="#photos#" index="photo">
                        <div>
                            <cfif photo.isImage()>
                                <img src="#photo.getPreviewURL()#" style="width: 300px; height: auto;">
                            <cfelse>
                                <div>The file you uploaded is not an image. Preview not available.</div>
                            </cfif>
                        </div>
                    </cfloop>
                </div>
            <cfelse>
                <cfdump var="#photos#" abort>
            </cfif>
        </div>
        <div>
        </div>
    </div>
</cfoutput>