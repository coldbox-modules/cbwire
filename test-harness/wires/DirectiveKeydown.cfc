component extends="cbwire.models.Component" {

    data = {
        "lastTyping": now()
    };

    function updateTime() {
        data.lastTyping = now();
    }
}	