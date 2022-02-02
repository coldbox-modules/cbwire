component {

    property name="cbwireManager" inject="CBWireManager@cbwire";

    function onCBWireSubsequentRequest( event, rc, prc ){
        var cbwireComponent = cbwireManager.getComponentInstance( rc.wireComponent );
        var memento = cbwireComponent.$hydrate( rc ).subsequentRenderIt().$getMemento();
        event.setValue( "_cbwire_subsequent_memento", memento );
    }
}