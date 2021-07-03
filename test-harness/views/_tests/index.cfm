<cfscript>
    filePaths = directoryList( path=expandPath( "/views/_tests" ), sort="name" );

    filePaths = filePaths.filter( function( filePath ){
        return !filePath.contains( "index.cfm" );
    } );
</cfscript>

<cfloop array="#filePaths#" index="filePath">
    <cfoutput><a href="#getFileFromPath( filePath )#">#filePath#</a><br></cfoutput>
</cfloop>
