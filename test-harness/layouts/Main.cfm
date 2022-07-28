<cfoutput>
<!doctype html>
<html>
<head>
<meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>CBWIRE Examples</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-gH2yIJqKdNHPEq0n4Mqa/HGKIhSkIHeL5AyhkYV8i59U5AR6csBvApHHNl/vI1Bx" crossorigin="anonymous">
	<link href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/11.6.0/styles/default.min.css" rel="stylesheet">
	<script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/11.6.0/highlight.min.js"></script>
	<script>hljs.highlightAll();</script>
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
		<div class="row">
			<div class="col-12">
				<h1><a href="/examples/index">CBWIRE Examples</a></h1>
			</div>
		</div>
		<div class="row">
			<div class="col-12">
				#renderView()#
			</div>
		</div>
	</div>
	#wireScripts()#
</body>
</html>
</cfoutput>