<cfoutput>
<!doctype html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>CBWIRE Examples</title>
	<link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;700&display=swap" rel="stylesheet">
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.0/dist/css/bootstrap.min.css" rel="stylesheet">
	<link href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/11.6.0/styles/default.min.css" rel="stylesheet">
	<script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/11.6.0/highlight.min.js"></script>
	<script src="https://kit.fontawesome.com/7e32a713f5.js" crossorigin="anonymous"></script>
	<style>
		html, body {
            height: 100%;
            margin: 0;
            padding: 0;
            font-family: 'Nunito', sans-serif;
        }
		.navcol ul {
			list-style-type: none;
			padding: 0;
		}
		.navcol ul li a {
			padding-left: 20px;
		}
		.navcol {
			padding: 20px;
			background-image: linear-gradient(to bottom, ##333, ##222); /* Darker gradient */
			color: ##fff;
			min-height: 100vh;
			overflow-y: auto;
			width: 350px;
			flex: 0 0 350px; /* Prevents the column from shrinking */
		}
		.navcol a {
			color: ##FFD700; /* Gold for links to match the logo's yellow */
			text-decoration: none;
			display: block;
			padding: 10px 0;
		}
		.navcol a:hover {
			background-color: rgba(255, 215, 0, 0.2); /* Lighter yellow on hover */
			text-decoration: none;
		}
		.btn {
			min-width: 120px; /* Ensures a minimum width for buttons */
		}
		.btn-primary {
			background-color: ##FFD700; /* Gold */
			border-color: ##FFD700;
			color: ##333; /* Dark text on gold */
		}
		.btn-primary:hover {
			background-color: ##FFEA00; /* Lighter gold for hover effect */
			border-color: ##FFEA00;
			color: ##333; /* Dark text on gold */
		}
		.btn-primary:focus {
			background-color: ##FFD700; /* Gold */
			border-color: ##FFD700;
			color: ##333; /* Dark text on gold */
			box-shadow: none;  /* Removes Bootstrap default focus shadow */
		}
		.btn-secondary:focus {
			border-color: transparent;  /* Removes the gray border */
			box-shadow: none;  /* Eliminates any focus shadow */
		}
		.btn {
            border-radius: 5px;
            transition: background-color 0.3s ease;
			box-shadow: none;
        }
		.btn:not(:disabled):not(.disabled):active {
			border-color: transparent !important; /* Ensures the gray border is removed, even if other styles are applied */
			box-shadow: none !important;  /* Ensures no shadow appears */
			background-color: inherit !important; /* Maintains the same background color on active */
		}

		.btn-primary:not(:disabled):not(.disabled):active {
			background-color: ##FFD700 !important; /* Specific color for primary button active state */
		}

		.btn-secondary:not(:disabled):not(.disabled):active {
			background-color: ##505050 !important; /* Sets a custom darker gray for active state */
        	color: white !important; /* Ensures text color is white for better readability */
		}
		.card {
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }
		.right-content {
			flex: 1; /* Takes up the remaining space */
		}
		.form-container {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            max-width: 400px;
            margin: auto;
        }
        .form-control:focus {
            border-color: ##FF6B6B;
            box-shadow: 0 0 0 0.2rem rgba(255, 107, 107, 0.25);
        }
	</style>
</head>
<body>
	<div class="container-fluid h-100">
		<div class="row h-100">
			<div class="col-3 navcol">
				<h2>CBWIRE 4</h2>
				<ul>
					<li><a wire:navigate href="/examples/Form">Form</a></li>
					<li><a wire:navigate href="/examples/DataProperties">Data Properties</a></li>
					<li><a wire:navigate href="/examples/Actions">Actions</a></li>					
					<li><a wire:navigate href="/examples/ComputedProperties">Computed Properties</a></li>
					<li><a wire:navigate href="/examples/ComputedPropertiesCache">Computed Properties Cache</a></li>
					<li><a wire:navigate href="/examples/DataBinding">Data Binding</a></li>
					<li><a wire:navigate href="/examples/Listeners">Listeners</a></li>
					<li><a wire:navigate href="/examples/QueryString">Query String</a></li>
					<li><a wire:navigate href="/examples/OnHydrate">onHydrate</a></li>
					<li><a wire:navigate href="/examples/OnUpdate">onUpdate</a></li>
					<li><a wire:navigate href="/examples/Entangle">entangle</a></li>
					<li><a wire:navigate href="/examples/InlineWire">Inline Component</a></li>
					<li><a wire:navigate href="/examples/ParentChildComponent">Parent/Child Component</a></li>
					<li><a wire:navigate href="/examples/Teleport">Teleport</a></li>
					<li><a wire:navigate href="/examples/JS">JS</a></li>
					<li><a wire:navigate href="/examples/Stream">Stream</a></li>
					<li><a wire:navigate href="/examples/LazyLoading">Lazy Loading</a></li>
				</ul>

				<h2>Forms</h2>
				<ul>
					<li><a wire:navigate href="/examples/TextInput">Text Input</a></li>
					<li><a wire:navigate href="/examples/CheckboxInput">Checkbox Input</a></li>
					<li><a wire:navigate href="/examples/RadioInput">Radio Input</a></li>
					<li><a wire:navigate href="/examples/SelectInput">Select Input</a></li>
					<li><a wire:navigate href="/examples/MultiselectInput">Multiselect Input</a></li>
					<li><a wire:navigate href="/examples/SubmitButton">Submit Button</a></li>
					<li><a wire:navigate href="/examples/FormValidation">Validation</a></li>
					<li><a wire:navigate href="/examples/FileUpload">File Upload</a></li>
				</ul>

				<h2>Template Directives</h2>	
				<ul>
					<li><a wire:navigate href="/examples/DirectiveModel">:model</a></li>
					<li><a wire:navigate href="/examples/DirectiveClick">:click</a></li>
					<li><a wire:navigate href="/examples/DirectiveKeydown">:keydown</a></li>
					<li><a wire:navigate href="/examples/DirectiveLoading">:loading</a></li>
					<li><a wire:navigate href="/examples/DirectiveDirty">:dirty</a></li>
					<li><a wire:navigate href="/examples/DirectivePoll">:poll</a></li>
					<li><a wire:navigate href="/examples/DirectiveInit">:init</a></li>
				</ul>
			</div>
			<div class="col right-content">
				<!-- Right column for content -->
				#renderView()#
			</div>
		</div>
	</div>
	<script>
		hljs.highlightAll();
		document.addEventListener("turbo:load", () => {
			hljs.highlightAll();
		});
	</script>
</body>
</html>
</cfoutput>