/**
 * This component provides utility functions for data manipulation.
 */
component {

    /**
     * Retrieves the value from a structure based on a given path.
     *
     * @param structure The structure to retrieve the value from.
     * @param path The path to the value in dot notation.
     * @return The value found at the specified path.
     * @throws KeyNotFoundException if the specified key is not found in the structure.
     */
    function getValueByPath(data, path) {
        var keys = listToArray(path, ".");
        var current = data;

        for (var i = 1; i <= arrayLen(keys); i++) {
            var key = keys[i];
            
            if (isArray(current)) {
                // Adjust for 1-based array indexing in ColdFusion
                var index = (isNumeric(key) ? key + 1 : arrayLen(current) + 1);
                
                if (index <= 0 || index > arrayLen(current)) {
                    throw("ArrayIndexOutOfBoundsException", "Index '#index#' is out of bounds in the array.");
                }

                current = current[index];
            } else if (isStruct(current) && structKeyExists(current, key)) {
                current = current[key];
            } else {
                throw("KeyNotFoundException", "Key or index '#key#' not found in the structure or array.");
            }
        }

        return current;
    }


    /**
     * Sets the value of a nested structure by providing a path.
     *
     * @param {struct} structure - The structure to modify.
     * @param {string} path - The path to the value in dot notation.
     * @param {any} value - The value to set.
     * @return {void}
     */
    function setValueByPath(data, path, value) {
        var keys = listToArray(path, ".");
        var current = data;

        for (var i = 1; i <= arrayLen(keys); i++) {
            var key = keys[i];

            // Check if the current context is an array and the key is numeric
            if (isArray(current) && isNumeric(key)) {
                // Adjust for 1-based array indexing in ColdFusion
                key = key + 1;

                // Check if the key is within the array bounds
                if (key <= 0 || key > arrayLen(current)) {
                    throw("ArrayIndexOutOfBoundsException", "Index '#key#' is out of bounds in the array.");
                }
            }

            // If it's the last key, set the value
            if (i == arrayLen(keys)) {
                current[key] = value;
            } else {
                // Check if the current context is a struct and the key does not exist or is not a struct/array
                if (isStruct(current) && (!structKeyExists(current, key) || (!isStruct(current[key]) && !isArray(current[key])))) {
                    current[key] = {}; // Initialize a new struct for the next level
                } else if (isArray(current) && (key > arrayLen(current) || !isStruct(current[key]) && !isArray(current[key]))) {
                    current[key] = {}; // Initialize a new struct for the next level
                }
                // Move to the next level in the structure or array
                current = current[key];
            }
        }
    }
}