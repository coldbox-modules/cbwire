/*
    I'm a pretend knock knock service. I return a single knock knock joke,
    and I simulate getting a response from something like ChatGPT.,
*/
component {

    variables.jokes = [
        "Why do programmers prefer dark mode? Because light attracts bugs!",
        "How do you comfort a JavaScript bug? You console it.",
        "Why do Java developers wear glasses? Because they don’t C##.",
        "I’ve got a really good UDP joke to tell you, but you might not get it.",
        "A programmer’s wife tells him, 'While you’re at the store, get some milk.' He never comes back.",
        "Why do programmers hate nature? It has too many bugs.",
        "How many programmers does it take to change a light bulb? None, that’s a hardware problem.",
        "Why was the JavaScript developer sad? Because he didn’t Node how to Express himself.",
        "Why do Python programmers prefer snakes? Because they're not Java fans!",
        "How do you explain the movie Inception to a programmer? It’s a function within a function within a function.",
        "Why did the developer go broke? Because he used up all his cache.",
        "Why was the function a bad team player? It always passed the buck.",
        "What's a developer's favorite hangout place? Foo bar.",
        "What do you call a programmer from Finland? Nerdic.",
        "Why do programmers prefer their own code? Because it's easier to read other people's minds than their code.",
        "What do computers and air conditioners have in common? They both become useless when you open windows.",
        "Why don't programmers like nature? Too many bugs.",
        "How does a programmer open a jar? He installs Java.",
        "Why was the JavaScript developer sad? He didn't know how to Express his feelings.",
        "Why don't programmers like to go outside? The sunlight causes too many glares on their screens.",
        "How many programmers does it take to screw in a light bulb? None, that's a hardware issue.",
        "Why do programmers always mix up Christmas and Halloween? Because Oct 31 == Dec 25.",
        "What's a programmer's favorite place to hangout? The foo bar.",
        "What kind of music do coders listen to? Heavy metal, because they love to rock.",
        "What do you call a programmer from Norway? A Norse code interpreter.",
        "What's the object-oriented way to become wealthy? Inheritance.",
        "Why do developers hate pranks? Because they have too many commit-ments.",
        "What do you call a group of 8 Hobbits? A Hobbyte.",
        "How did the developer announce his engagement? He said, 'She finally accepted my commit.'",
        "Why do Python programmers wear glasses? Because they can't C."
    ];

    function getJoke( callback ) {
        // Grab a random joke
        var joke = variables.jokes[randRange( 1, jokes.len() )];
        // Check for a callback
        if ( !isNull( arguments.callback ) && isCustomFunction( arguments.callback ) ) {
            // We have a callback so let's simulate ChatGPT by
            // breaking the joke into words, looping over them,
            // and passing them to the callback one word at a time.
            var words = joke.split( " " );
            for ( var i = 1; i <= arrayLen( words ); i++ ) {
                arguments.callback( words[i] & " " );
                // Pretend this is ChatGPT and it's slow
                sleep( 300 );
            }
            // Return last chunk as an empty string
            return "";
        }
        // No callback so just return the joke, but pretend it takes a while
        sleep( 5000 ); 
        return joke;
    }

}