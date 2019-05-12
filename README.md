# Wolfram Language support for google-code-prettify
 
This is the official Mathematica and Wolfram Language code highlighter for [Mathematica.stackexchange.com](http://mathematica.stackexchange.com/)
and [the Wolfram Community](http://community.wolfram.com).

To use it with your installation of [google-code-prettify](http://code.google.com/p/google-code-prettify/), you have to
add the files (probably the minified versions) from the `src` folder into your code-pretty installation. The file `lang-mma.min.js` needs to go into
the `google-code-prettify/src` folder and the `prettify-mma.min.css` needs to go into the `styles` folder.
The difference between `lang-mma.js` and `lang-mma.min.js` is that the latter one is the *minimized* js-file.
All other information can be found in the [google-code-prettify wiki](http://code.google.com/p/google-code-prettify/wiki/GettingStarted).

Note that I also compiled a [Joomla extension](https://github.com/halirutan/JPrettify) which lets you easily install the whole
highlighting engine on your Joomla based website.

The `resources` folder contains another file: `mathematica-source-highlighter.user.js` which is a browser userscript that was used
to test the highlighter before it was officially installed at Stack Exchange.
The JavaScript can be opened with Google Chrome and is then installed as a local extension.
When you browse pages under http://stackoverflow.com/questions/ and have Mathematica code posted
on the page its style is replaced and you should see nice code highlighting.

This user-script was written by Tim Stone and I only added the rules for the lexical scanner and
colors which go along with the page colors of StackOverflow.
