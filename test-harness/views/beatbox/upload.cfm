<cfoutput>
    <div class="container">
        <h1>Upload</h1>
        <form action="uploadAction.cfm" method="post" enctype="multipart/form-data">
            <div class="mb-3">
                <label for="audioFile" class="form-label">Audio File</label>
                <input type="file" class="form-control" id="audioFile" name="audioFile">
            </div>
            <button type="submit" class="btn btn-primary">Upload</button>
        </form>
    </div>
</cfoutput>
