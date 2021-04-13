component accessors="true" {

    property name="event";
    property name="wirebox" inject="wirebox";
    property name="initialRendering" default="true";

    function init( required RequestContext event ) {
        this.setEvent( event );
    } 

    function getId() {
        // match Livewire's 21 characters
        return createUUID().replace( "-", "", "all" ).left( 21 );
    }

    function getInitialPayload() {
        return {
            "fingerprint": {
                "id": "#getID()#",
                "name": "#getMetaData( this ).name#",
                "locale": "en",
                "path": "/",
                "method": "GET"
            },
            "effects": {
                "listeners": []
            },
            "serverMemo": {
                "children": [],
                "errors": [],
                "htmlHash": "ac82b577",
                "data": getData(),
                "dataMeta": [],
                "checksum": "2731fee42e720ea86ae36f5f076eca0943c885857c098a55592662729341e9cb"
            }
        };
    }

    function getSubsequentPayload() {
        return {
            "effects": {
                "html": this.render(),
                "dirty": [
                    "count" // need to fix
                ]
            },
            "serverMemo": {
                "htmlHash": "71146cf2",
                "data": getData(),
                "checksum": "1ca298d9d162c7967d2313f76ba882d9bce208822308e04920c2080497c04fc1"
            }
        }
    }

    function getData() {
        return getMetaData( this ).properties.reduce( function ( agg, prop ){
            if ( structKeyExists( this, "get" & prop.name ) ) {
                agg[ prop.name ] = this[ "get" & prop.name ]();
            }
            return agg;
        }, {} );
    }

    function hydrate() {

        var context = getEvent().getCollection();

        setInitialRendering( false );

        if ( structKeyExists( context, "serverMemo") && structKeyExists( context.serverMemo, "data") ) {
            context.serverMemo.data.each( function( key, value ) {
                this[ "set#key#"]( value );
            });
        }

        if ( structKeyExists( context, "updates") ) {
            context.updates.each( function( thisUpdate ) {

                if ( thisUpdate.type == "callMethod" ) {
                    this[ thisUpdate["payload"]["method"] ]();
                }

                if ( thisUpdate.type == "syncInput" ) {
                    this[ "set" & thisUpdate["payload"]["name"] ]( thisUpdate["payload"]["value"] );
                }

            } );
        }

        return getSubsequentPayload();
    }

    function renderView() {
        var renderer = wirebox.getInstance( "Renderer@coldbox" );
        // Pass the properties of the Livewire component as variables to the view
        arguments.args = getData();

        var rendering = renderer.renderView( argumentCollection=arguments );

        // Add livewire properties to top element to make livewire actually work
        // We will need to make this work with more than just <div>s of course
        if ( getInitialRendering() ) {
            rendering = rendering.replaceNoCase( "<div", "<div wire:id=""#getId()#"" wire:initial-data=""#serializeJson( getInitialPayload() ).replace('"', '&quot;', 'all')#""", "once" );
        } else {
            rendering = rendering.replaceNoCase( "<div", "<div wire:id=""#getId()#""", "once" );
        }

        return rendering;
    }    

}