<cfoutput>
    <div class="row">
        <div class="col-12">
            <div class="row">
                <div class="col-6">
                    <h1><a href="/examples/index">CBWIRE Examples</a></h1>
                </div>
                <div class="col-6">
                    <div class="d-flex flex-row-reverse mt-3">
                        <a href="https://github.com/coldbox-modules/cbwire"><i class="fa-brands fa-github fa-2xl me-4" title="GitHub"></i></a>
                        <a href="https://cbwire.ortusbooks.com"><i class="fa-solid fa-book-sparkles fa-2xl me-4" title="Documentation"></i></a>
                    </div>
                </div>
            </div>
            <div class="row">
                <cfif len( args.example )>
                    <div class="col-12">
                        page: #args.example#
                        #wire( args.example )#
                    </div>
                </cfif>
                <div class="col-12 mt-4">
                    <h2>Components2</h2>
                </div>
                <div class="col-3 pt-3">
                    <a wire:click.prevent="showExample('DataProperties')" class="btn btn-primary w-100">Data Properties</a>
                </div>
                <div class="col-3 pt-3">
                    <a class="btn btn-primary w-100" href="/examples/Actions">Actions</a>
                </div>
                <div class="col-3 pt-3">
                    <a class="btn btn-primary w-100" href="/examples/CallAction">Call Action</a>
                </div>
                <div class="col-3 pt-3">
                    <a class="btn btn-primary w-100" href="/examples/Listeners">Listeners</a>
                </div>
                <div class="col-12 mt-4">
                    <h2>Form Elements</h2>
                </div>
                <div class="col-3 pt-3">
                    <a class="btn btn-primary w-100" href="/examples/TextInput">Text Input</a>
                </div>
                <div class="col-3 pt-3">
                    <a class="btn btn-primary w-100" href="/examples/CheckboxInput">Checkbox Input</a>
                </div>
                <div class="col-3 pt-3">
                    <a class="btn btn-primary w-100" href="/examples/RadioInput">Radio Input</a>
                </div>
                <div class="col-3 pt-3">
                    <a class="btn btn-primary w-100" href="/examples/SelectInput">Select Input</a>
                </div>
                <div class="col-3 pt-3">
                    <a class="btn btn-primary w-100" href="/examples/MultiselectInput">Multiselect Input</a>
                </div>
                <div class="col-3 pt-3">
                    <a class="btn btn-primary w-100" href="/examples/SubmitButton">Submit Button</a>
                </div>
                <div class="col-12 mt-4">
                    <h2>Template Directives</h2>
                </div>
                <div class="col-3 pt-3">
                    <a class="btn btn-primary w-100" href="/examples/DirectiveModel">:model</a>
                </div>
                <div class="col-3 pt-3">
                    <a class="btn btn-primary w-100" href="/examples/DirectiveClick">:click</a>
                </div>
                <div class="col-3 pt-3">
                    <a class="btn btn-primary w-100" href="/examples/DirectiveKeydown">:keydown</a>
                </div>
                <div class="col-3 pt-3">
                    <a class="btn btn-primary w-100" href="/examples/DirectiveLoading">:loading</a>
                </div>
                <div class="col-3 pt-3">
                    <a class="btn btn-primary w-100" href="/examples/DirectiveDirty">:dirty</a>
                </div>
                <div class="col-3 pt-3">
                    <a class="btn btn-primary w-100" href="/examples/DirectivePoll">:poll</a>
                </div>
                <div class="col-3 pt-3">
                    <a class="btn btn-primary w-100" href="/examples/DirectiveInit">:init</a>
                </div>
            </div>
        </div>
    </div>
</cfoutput>