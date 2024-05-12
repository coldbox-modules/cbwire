<cfoutput>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>CBWIRE Examples</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;700&display=swap" rel="stylesheet">
    <!-- Stylesheets -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/11.6.0/styles/github-dark.min.css" rel="stylesheet">
	<link href="/includes/css/styles.css" rel="stylesheet">
    <!-- Scripts -->
    <script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/11.6.0/highlight.min.js"></script>
    <script src="https://kit.fontawesome.com/7e32a713f5.js" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.0/dist/js/bootstrap.bundle.min.js"></script> <!-- Include Bootstrap JS -->
</head>
<body>
    <nav class="navbar navbar-expand-md navbar-dark bg-dark sticky-top" aria-label="Your navbar example">
        <div class="container-xl">
            <a class="navbar-brand" href="/beatbox/index">BeatBox</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="##navbarNavDropdown" aria-controls="navbarNavDropdown" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNavDropdown">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link active" aria-current="page" href="/beatbox/index">Home</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="/beatbox/loops">Loops</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="/beatbox/upload">Upload</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="/beatbox/contact">Contact</a>
                    </li>
                </ul>
            </div>
            <form method="get" action="/beatbox/loops" class="d-flex">
                <input class="form-control me-2" type="search" name="search" placeholder="Loop name, BPM..." aria-label="Search">
                <button class="btn btn-outline-success" type="submit">Search</button>
            </form>
        </div>
    </nav>
    <div class="container">
        <div class="row">
            <div class="col right-content">
                <!-- Right column for content -->
                <div class="my-5">
                    #renderView()#
                </div>
            </div>
        </div>
    </div>
    <footer class="footer">
		<div class="container">
			<p class="mb-0">&copy; #year( now() )# BeatBox | Powered by CBWIRE</p>
		</div>
	</footer>
    <div id="audioPlayer" class="audio-player d-none">
        <audio id="audioElement" controls>
            <source id="audioSource" src="" type="audio/mp3">
            Your browser does not support the audio element.
        </audio>
    </div>
    <script>
        // Code highlighting with highlight.js
        document.addEventListener("livewire:navigated", () => {
            hljs.highlightAll();
        });
        // Play audio loop
        function playLoop(loopName) {
            // Map loop names to audio sources here
            const audioSources = {
                "Loop 1": "/audio/loop1.mp3",
                "Loop 2": "/audio/loop2.mp3",
                // Add more loops as needed
            };

            // Retrieve the audio source
            const audioSource = "/includes/audio/1.mp3";

            if (audioSource) {
                // Set the audio source to the selected loop
                const audioElement = document.getElementById("audioElement");
                const sourceElement = document.getElementById("audioSource");
                sourceElement.src = audioSource;
                audioElement.load();

                // Show the audio player by toggling the show class
                const audioPlayer = document.getElementById("audioPlayer");
                audioPlayer.classList.remove("d-none");
                audioPlayer.classList.add("show");

                // Start playing the audio
                audioElement.play();
            } else {
                console.error("Audio source not found for loop:", loopName);
            }
        }
</script>
</body>
</html>
</cfoutput>