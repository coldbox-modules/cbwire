<cfoutput>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>CBWIRE Examples</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-gH2yIJqKdNHPEq0n4Mqa/HGKIhSkIHeL5AyhkYV8i59U5AR6csBvApHHNl/vI1Bx" crossorigin="anonymous">
	<style type="text/css">
		.btn-primary, .btn-primary:focus {
			border-color: ##fcd34d;
			background-color: ##fcd34d;
			color: ##000000;
		}
		.btn-primary:hover {
			border-color: ##fcd34d;
			background-color: ##eab308;
		}
		.code {
			background-color: ##eeeeee;
			padding: 10px;
		}
	</style>
	#wireStyles()#
</head>
<body>
	<div class="container pt-3">
		<h1><a href="/examples/index">CBWIRE Examples</a></h1>
		<div class="mt-4">
			#renderView()#
		</div>
	</div>
	#wireScripts()#
</body>
</html>
</cfoutput>