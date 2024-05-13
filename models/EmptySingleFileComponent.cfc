component extends="cbwire.models.Component" {

    {{ CFC_CONTENTS }}

    function renderIt() {
        return view( "{{ TEMPLATE_PATH }}" );
    }

}