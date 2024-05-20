<cfoutput>
    <div>
        #serializejson( data )#
        <h1>Alpine Upload</h1>
        <form wire:submit="save">
            <div
                x-data="{ uploading: false, progress: 0 }"
                x-on:cbwire-upload-start="uploading = true"
                x-on:cbwire-upload-finish="uploading = false"
                x-on:cbwire-upload-cancel="uploading = false"
                x-on:cbwire-upload-error="uploading = false"
                x-on:cbwire-upload-progress="progress = $event.detail.progress"
            >
                <!-- File Input -->
                <input type="file" wire:model="photo">

                <cfif isObject( photo ) and photo.isImage()>
                    <img src="#photo.getPreviewURL()#" alt="Photo">
                </cfif>

                <div style="margin-top: 300px;" wire:loading wire:target="photo">Loading....</div>
        
                <!-- Progress Bar -->
                <div x-show="uploading">
                    <progress max="100" x-bind:value="progress"></progress>
                </div>
            </div>
        </form>
    </div>
</cfoutput>

<cfscript>
    // @startWire
    data = {
        "photo": ""
    };

    // @endWire
</cfscript>