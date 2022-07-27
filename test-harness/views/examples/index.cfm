<cfscript>
    filePaths = directoryList( path=expandPath( "/views/examples" ), sort="name" );

    filePaths = filePaths.filter( function( filePath ){
        return !filePath.contains( "index.cfm" );
    } ).map( function( filePath ) {
        return getFileFromPath( filePath );
    });
</cfscript>

<cfoutput>
<div class="row">
    <cfloop array="#filePaths#" index="filePath">
        <div class="col-3 pt-3">
            <a class="btn btn-primary" href="#filePath#">#filePath#</a>
        </div>
    </cfloop>
</div>
</cfoutput>
