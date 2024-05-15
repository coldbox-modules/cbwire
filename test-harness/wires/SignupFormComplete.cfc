component extends="cbwire.models.Component" {

    data = {
        "name": "",
        "email": "",
        "zip": "",
        "submitted": false
    };

    // constraints = {
    //     "name": { "required": true },
    //     "zip": { "required": true, "regex": "^[0-9]{5}" },
    //     "email": { "required": true, "type": "email", typeMessage: "Your email is whack!" },
    // };

    function submitForm() {
        sleep( 1000 );
        reset();
        //data.submitted = true;
        js( '
            Swal.fire({
                title: "Good job!",
                text: "You clicked the button!",
                icon: "success"
            });
        ' );

        return "yay!";
    }
}