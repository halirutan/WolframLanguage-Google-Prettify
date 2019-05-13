// Copyright (C) 2019 Patrick Scheibe
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


/**
 * @fileoverview
 * Registers a language handler for Mathematica.
 *
 *
 * To use, include prettify.js and this file in your HTML page.
 * Then put your code in an HTML tag like
 *      <pre class="prettyprint lang-mma"></pre>
 *
 * History:
 *
 * 05/13/2019 Update to Wolfram Language version 12. Changing the regex for matching
 * all the built-in symbols into a trie like structure.
 *
 * 01/22/2017 Updated to Mathematica 11.0.1
 *
 * 01/22/2016 Update to Mathematica version 10.3.1
 *
 * 07/11/2014 Update to Mathematica version 10
 *
 * 02/23/2013 Updated keywords and named symbols to Mathematica Version 9.0.1
 *
 * 02/01/2012 Implemented the full range of number formats.
 *
 * 01/30/2012 Fixed missing '?' in the operator list. Included named-characters like \[Gamma] to give a complete match
 * for such symbols. Added $variables in the keyword list.
 * Improved the matching of patterns. Added matching of context constructions like Developer`PackedArrayQ.
 * Switch of the color-scheme due to many requests. Now it's like in the Mathematica-frontend. Keywords black, variables blue.
 *
 * 01/30/2012 Fixed missing '?' in the operator list. Included named-characters like \[Gamma] to give a complete match
 * for such symbols.
 *
 * 01/25/2012 Added the recognition of Mathematica-numbers. This should now highlight things like
 * {1, 1.0, 1., .12, 16^^1.34f, ...}. Additionally it should recognize the backtick behind a number.
 * I switched comments and strings to gray and use a dark red for the numbers.
 *
 * 01/23/2012 Initial version.
 *
 *
 * @author patrick@halirutan.de (www.halirutan.de)
 */

(function () {

    var keywords = new RegExp("^$$KEYWORDS$$\\b");
    var namedCharacters =  new RegExp("\\\\\\[$$NAMEDCHARACTERS$$]");
    var numbers = new RegExp("^(?:(?:(?:[2-9]|[1-2]\\d|[3][0-5])\\^\\^(?:\\w*\\.\\w+|\\w+\\.\\w*|\\w+))|(?:\\d*\\.\\d+|\\d+\\.\\d*|\\d+))(?:(?:``(?:[+\\-])?(?:\\d*\\.\\d+|\\d+\\.\\d*|\\d+))|(?:`(?:(?:[+\\-])?(?:\\d*\\.\\d+|\\d+\\.\\d*|\\d+))?))?(?:\\*\\^(?:[+\\-])?\\d+)?");

    var shortcutStylePatterns = [
        // Whitespaces, linebreaks, tabs
        [PR.PR_PLAIN,   /^[\t\n\r \xA0]+/, null, '\t\n\r \xA0'],

        [PR.PR_STRING,      /^(?:"(?:[^"\\]|\\[\s\S])*(?:"|$))/, null, '"']

    ];

    var fallthroughStylePatterns = [

        // Flat comments. Start with (* and end with *). Can go over several lines and must not be nested.
        [PR.PR_COMMENT, /^\(\*[\s\S]*?\*\)/, null],

        // Numbers
        [PR.PR_LITERAL, numbers, null],

        ['mma_iot', /^(?:In|Out)\[[0-9]*]/,null],

        ['lang-mma-usage', /^([a-zA-Z$]+(?:`?[a-zA-Z0-9$])*::[a-zA-Z$][a-zA-Z0-9$]*):?/,null],

        // this makes a look-ahead match for something like variable:{_Integer}
        // the match is then forwarded to the mma-patterns tokenizer.
        ['lang-mma-patterns',/^([a-zA-Z$][a-zA-Z0-9$]*\s*:)(?:(?:[a-zA-Z$][a-zA-Z0-9$]*)|(?:[^:=>~@^&*)\[\]'?,|])).*/, null],

        // catch variables which are used together with Blank (_), BlankSequence (__) or BlankNullSequence (___)
        // Cannot start with a number, but can have numbers at any other position. Examples
        // blub__Integer, a1_, b34_Integer32
        //[PR.PR_ATTRIB_VALUE, new RegExp('^(?:'+p_variable+'|'+namedCharacters+')_+'+p_variable+'*'), null],
        [PR.PR_ATTRIB_VALUE, /^[a-zA-Z$][a-zA-Z0-9$]*_+[a-zA-Z$][a-zA-Z0-9$]*/, null],
        [PR.PR_ATTRIB_VALUE, /^[a-zA-Z$][a-zA-Z0-9$]*_+/, null],
        [PR.PR_ATTRIB_VALUE, /^_+[a-zA-Z$][a-zA-Z0-9$]*/, null],

        // Named characters in Mathematica, like \[Gamma]. This list was created with
        // the functions in /resources/Boostrap.m
        [PR.PR_ATTRIB_NAME, namedCharacters, null],

        // Match all braces separately
        [PR.PR_TAG, /^[\[\]{}()]/,null],

        // Catch Slots (#, ##, #3, ##9 and the V10 named slots #name). I have never seen someone using more than one digit after #, so we match
        // only one.
        [PR.PR_ATTRIB_VALUE, /^(?:#[a-zA-Z$][a-zA-Z0-9$]*|#+[0-9]?)/,null],

        // The large list of keywords from above can be created with the functions in /resources/Boostrap.m
        [PR.PR_KEYWORD, keywords, null],

        // Literals like variables, non-keyword functions
        [PR.PR_PLAIN, /^[a-zA-Z$][a-zA-Z0-9$`]*/, null],

        // operators. Note that operators like @@ or /; are matched separately for each symbol.
        [PR.PR_PUNCTUATION, /^[+\-*\/,;.:@~=><&|_`'^?!%]/, null]

    ];

    var fallthroughStylePatternsMathematicaPatterns = [
        [PR.PR_ATTRIB_VALUE, /^(?:[a-zA-Z$][a-zA-Z0-9$]*\s*:)/,null]
    ];

    var fallthroughMathematicaUsage = [
        ['mma_use', /^([a-zA-Z$]+(?:`?[a-zA-Z0-9$])*::usage)/,null],
        ['mma_msg', /^([a-zA-Z$]+(?:`?[a-zA-Z0-9$])*::[a-zA-Z$][a-zA-Z0-9$]*)/,null]

    ];

    PR.registerLangHandler(PR.createSimpleLexer(shortcutStylePatterns, fallthroughStylePatterns), ['mma', 'mathematica']);
    PR.registerLangHandler(PR.createSimpleLexer([], fallthroughStylePatternsMathematicaPatterns), ['mma-patterns']);
    PR.registerLangHandler(PR.createSimpleLexer([], fallthroughMathematicaUsage), ['mma-usage']);

})();

