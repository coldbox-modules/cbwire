<cfoutput>#wire( "workshop.NestedDataKeys" )#</cfoutput>
<cfif application.keyExists( "cbwire_interceptors_run" ) >
	<hr>
	<div class="alert alert-info" role="alert">
	The cfdump below is NOT coming from the wire component, but from the nestedDataKeys.cfm view after the wire has rendered.<br>
	It shows any CBWire interceptors that ran during the wire lifecycle for this inital page render.<br>
	The data is being injected into the application scope by the TestHarnessInterceptor.cfc interceptor.<br>
	The application.cbwire_interceptors_run structure is cleared at the start of the Workshop.nestedDataKeys() handler method to ensure only the interceptors for this wire are shown.
	</div>
	<h3>CBWire Interceptors That Ran:</h3>
	<cfdump var="#application.cbwire_interceptors_run#" label="application.cbwire_interceptors_run" />
</cfif>