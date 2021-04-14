<cfoutput>
<!doctype html>
<html>
<head>
	#livewireStyles()#
</head>
<body>
	<h1>cbLivewire Tester</h1>
	<div>
		#renderView()#
	</div>

	#livewireScripts()#
</body>
</html>
</cfoutput>