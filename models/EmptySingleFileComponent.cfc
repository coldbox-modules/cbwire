component extends="cbwire.models.Component" {

    {{ CFC_CONTENTS }}

    function renderIt() {
        return template( "{{ TEMPLATE_PATH }}" );
    }

}