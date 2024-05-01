<cfoutput>
    <div>
        <h1>Forms</h1>

        <h2>Binding Data</h2>

        <div class="row">
            <div class="col-lg-8">
                <!--- code snippet --->
                #wire( name="ShowCode", params={ "wire": "DataBinding1" } )#
            </div>
            <div class="col-lg-4">
                #wire( name="DataBinding1", lazy=true )#
            </div>
        </div>
    </div>
</cfoutput>