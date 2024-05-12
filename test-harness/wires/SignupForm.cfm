<cfscript>
    sleep( 1500 ); // Simulate a typical requests 
    param name="form.name" default="";
    param name="form.email" default="";

    errors = [];

    if ( isDefined( "form.submitted" ) ) {
        submitted = true;

        if ( !len( form.name ) ) {
            errors.append( "name" );
        }

        if ( !len( form.email ) ) {
            errors.append( "email" );
        }
    } else {
        submitted = false;
    }
</cfscript>

<cfoutput>
<div>
    <h1>Signup Form</h1>

    <div class="form-container">
        <cfif errors.len() gt 0>
            <div class="alert alert-danger" role="alert">
                <strong>Error!</strong> Please correct the following errors:
                <ul>
                    <cfloop array="#errors#" index="error">
                        <li><strong>#error#</strong> is required.</li>
                    </cfloop>
                </ul>
            </div>
        </cfif>
        <form method="post" action="">
            <!-- First Name -->
            <div class="mb-3">
                <label for="name" class="form-label">Name</label>
                <input type="text" class="form-control" id="name" name="name" placeholder="Enter first name" value="#form.name#">
                <div class="text-danger" id="error-name"></div>
            </div>
            <!-- Email -->
            <div class="mb-3">
                <label for="email" class="form-label">Email</label>
                <input type="text" class="form-control" id="email" name="email" placeholder="Enter email" value="#form.email#">
                <div class="text-danger" id="error-email"></div>
            </div>
            <!-- Reset Button -->
            <button type="submit" name="submitted" class="btn btn-primary">Submit</button>
            <button type="reset" class="btn btn-secondary">Reset</button>

            <cfif submitted>
                <div class="mt-3 alert alert-success" role="alert">
                    <strong>Success!</strong> Your form has been submitted. #now()#
                </div>
            </cfif>
        </form>
    </div>
</div>
</cfoutput>