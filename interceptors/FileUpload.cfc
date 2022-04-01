component {

    function onCBWireFileUpload( event, data ) {
        var memento = {
            "effects": {
                "html": javacast( "null", 0 ),
                "emits": [
                {
                    "event": "upload:generatedSignedUrl",
                    "params": [
                    "photo",
                    "http://localhost/livewire/upload-file?expires=1648817149&signature=f7ac1a845425e5d1062a47659c22489a6a38709824ed7dd42a8f5f5a0ad3a38a"
                    ],
                    "selfOnly": true
                }
                ],
                "dirty": []
            },
            "serverMemo": {
                "checksum": "2f2c1a8b71bc1fc789d21903f500e39033202b94d2693c3357f59efa0ca05815"
            }
        };

        event.setValue( "_cbwire_file_upload_memento", memento );
    }

}