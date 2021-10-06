<cfset manifest = getInstance( "coldbox:setting:manifest@cbwire" )>

<cfoutput>
<!-- Livewire Scripts -->
<script src="/modules/cbwire/includes/js#manifest["/livewire.js"]#" data-turbo-eval="false" data-turbolinks-eval="false"></script>
<script data-turbo-eval="false" data-turbolinks-eval="false">
    if (window.livewire) {
	    console.warn('Livewire: It looks like Livewire\'s ##wireScripts()## JavaScript assets have already been loaded. Make sure you aren\'t loading them twice.')
	}

    window.livewire = new Livewire();
    window.livewire.devTools(true);
    window.Livewire = window.livewire;
    window.cbwire = window.livewire;
    window.livewire_app_url = '';
    window.livewire_token = 'caxTa7qUQqfONmG5vqz16Y5EvNEx77Eaadxnhyqi';

	/* Make sure Livewire loads first. */
	if (window.Alpine) {
	    /* Defer showing the warning so it doesn't get buried under downstream errors. */
	    document.addEventListener("DOMContentLoaded", function () {
	        setTimeout(function() {
	            console.warn("Livewire: It looks like AlpineJS has already been loaded. Make sure Livewire\'s scripts are loaded before Alpine.\\n\\n Reference docs for more info: http://laravel-livewire.com/docs/alpine-js")
	        })
	    });
	}

	/* Make Alpine wait until Livewire is finished rendering to do its thing. */
    window.deferLoadingAlpine = function (callback) {
        window.addEventListener('livewire:load', function () {
            callback();
        });
    };

    document.addEventListener("DOMContentLoaded", function () {
        window.livewire.start();
    });
</script>
</cfoutput>