<cfoutput>
	<cfif args.keyExists( "_wireName" ) && len( args._wireName ) >
		<cfif args.keyExists( "title" ) AND len(  args.title ) >
			#args.keyExists( "titleTag" ) && len( args.titleTag ) ? "<" & args.titleTag & ">" : "<h1>"#
			#args.title#
			#args.keyExists( "titleTag" ) && len( args.titleTag ) ? "</" & args.titleTag & ">" : "</h1>"#
		</cfif>
		#wire( name=args._wireName, params=args._wireParams )#
	<cfelse>
		<p style="color: black; background-color: ##E6B444;">
			<span style="font-weight: bold;">No wire component name specified for wireGenericView() method!</span><br>
			<span style="font-style: italics;">Please provide a valid component name as the first argument when calling this method.</span>
		</p>
	</cfif>
</cfoutput>