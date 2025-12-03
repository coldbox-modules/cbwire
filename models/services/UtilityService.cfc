component accessors="true" {

    /**
     * Checks whether a file exists at the given path.
     *
     * @path string - The absolute path to check.
     * @return boolean - True if the file exists, false otherwise.
     */
    function fileExists( required string path ) {
        return fileExists( arguments.path );
    }

}
