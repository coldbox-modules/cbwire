component extends="cbwire.models.Component" {

    {{ CFC_CONTENTS }}

    function onRender() {
        return template( "{{ TEMPLATE_PATH }}" );
    }

}