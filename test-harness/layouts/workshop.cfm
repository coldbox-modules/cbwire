<cfoutput>
    <!doctype html>
    <html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>CBWIRE Workshop Examples</title>
        <!-- Fonts -->
        <!--- <link href="/includes/workshop/font.css" rel="stylesheet"> --->
        <!-- Stylesheets -->
        <link href="/includes/workshop/bootstrap.min.css" rel="stylesheet">
        <link href="/includes/workshop/workshop.css" rel="stylesheet">
        <!-- Scripts -->
        <script src="/includes/workshop/sweetalert2.js"></script>
    </head>
    <body>
        <div class="container-fluid h-100">
            <div class="row h-100">
                <div class="col-3 navcol" id="sidebar">
                    <button class="nav-toggler w-100" id="navbarToggler">
                        CBWIRE
                    </button>
                    <ul>
                        <li><a href="/workshop/Counter">Counter</a></li>
                        <li><a href="/workshop/SignupForm">Signup Form</a></li>
                        <li><a href="/workshop/TaskList">Task List</a></li>
                    </ul>
                </div>
                <div class="col-9 right-content">
                    <div class="pt-5 px-5">
                        #renderView()#
                    </div>
                </div>
            </div>
        </div>
        <script>
            // Sidebar toggle button functionality
            document.addEventListener("DOMContentLoaded", () => {
                var sidebar = document.getElementById('sidebar');
                // var toggler = document.getElementById('navbarToggler');
                // toggler.addEventListener('click', function() {
                // 	var sidebarStyle = sidebar.style.transform;
                // 	sidebar.style.transform = sidebarStyle === 'translateX(0px)' ? 'translateX(-100%)' : 'translateX(0px)';
                // });
            });
            document.addEventListener("livewire:navigated", () => {
                
            });
        </script>
    </body>
    </html>
</cfoutput>