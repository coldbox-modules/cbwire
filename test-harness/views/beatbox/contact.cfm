<cfscript>
    // Check if form is submitted
    if ( rc.keyExists( "submit" ) ) {
        // Create errors array
        errors = [];
        sent = false;

        // Check each field for empty values
        if (rc.name.trim() eq "") {
            errors.append("Name is required.");
        }
        if (rc.email.trim() eq "") {
            errors.append("Email is required.");
        }
        if (rc.message.trim() eq "") {
            errors.append("Message is required.");
        }

        // If there are no errors, call beatBoxService.sendContact(rc)
        if ( !errors.len() ) {
            sent = true;
            // beatBoxService.sendContact( rc );
        }
    }
</cfscript>

<cfoutput>
    <div class="container">
        <h1>Contact</h1>
        <cfif variables.keyExists( "errors" ) and variables.errors.len() >
            <div class="alert alert-danger" role="alert">
                <ul>
                    <cfloop array="#variables.errors#" index="error">
                        <li>#error#</li>
                    </cfloop>
                </ul>
            </div>
        </cfif>
        <form method="post" action="">
            <div class="mb-3">
                <label for="name" class="form-label">Name</label>
                <input type="text" class="form-control" id="name" name="name" placeholder="Enter your name">
            </div>
            <div class="mb-3">
                <label for="email" class="form-label">Email</label>
                <input type="text" class="form-control" id="email" name="email" placeholder="Enter your email">
            </div>
            <div class="mb-3">
                <label for="message" class="form-label">Message</label>
                <textarea class="form-control" id="message" name="message" rows="5" placeholder="Enter your message"></textarea>
            </div>
            <button name="submit" type="submit" class="btn btn-primary">Submit</button>
        </form>
    </div>
</cfoutput>