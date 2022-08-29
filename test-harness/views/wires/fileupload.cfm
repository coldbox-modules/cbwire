<cfoutput>
    <div>
        <input wire:model="myFile" type="file">
        <a href="##" wire:click="save" class="btn btn-primary">Save</a>
        <div>
            <div wire:loading wire:target="myFile">Uploading...</div>
        </div>
        <div>
            <cfif isObject( args.myFile )>
                <cfif args.myFile.isImage()>
                    <img src="#args.myFile.getTemporaryURL()#" style="width: 300px; height: auto;">
                </cfif>
            <cfelse>
                <div>myfile = #args.myfile#</div>
            </cfif>
        </div>
    </div>
</cfoutput>