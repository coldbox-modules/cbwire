/**
 * CommandBox Task Runner for downloading and compiling Livewire's JS
 */
component {

    function run() {

        var livewireVersion = ask( message="What version of Livewire? " );

        var livewireDirectory = getCWD() & "/livewire";

        print.greenLine( "Pull git repo" ).toConsole();

        command( "!git pull origin master")
            .inWorkingDirectory( livewireDirectory )
            .run();

        print.greenLine( "Checkout out version #livewireVersion#" ).toConsole();

        command( "!git checkout #livewireVersion#")
            .inWorkingDirectory( livewireDirectory )
            .run();

        print.greenLine( "Compile JS assets" ).toConsole();

        command( "!npx -c rollup")
            .inWorkingDirectory( livewireDirectory )
            .run();

        print.greenLine( "Copy new JS assets into cbwire 'includes/js'" ).toConsole();

        command( "cp" )
            .params( path="livewire/dist", newpath="includes/js", filter="*.*" )
            .run();
        

    }
}