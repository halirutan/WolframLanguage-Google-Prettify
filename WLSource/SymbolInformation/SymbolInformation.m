(* Mathematica Package *)
(* Created by Mathematica Plugin for IntelliJ IDEA, see http://wlplugin.halirutan.de/ *)

(* :Author: Patrick Scheibe *)
(* :Date: 5/11/19 *)

Package["SymbolInformation`"]
PackageImport["JLink`"]

JLink`LoadJavaClass["de.halirutan.wlinfo.Utils"];

$thisDirectory = DirectoryName[System`Private`$InputFileName];
$publicUnicodeArea = Join[Range[16^^E000 - 1], Range[16^^F8FF + 1, 16^^FFFF]];

$builtInNamedCharacters = {"\\[Degree]", "\\[Pi]", "\\[Infinity]", "\\[SystemsModelDelay]",
  "\\[SpanFromLeft]", "\\[SpanFromAbove]", "\\[SpanFromBoth]",
  "\\[ExponentialE]", "\\[ImaginaryI]", "\\[ImaginaryJ]",
  "\\[FormalA]", "\\[FormalB]", "\\[FormalC]", "\\[FormalD]",
  "\\[FormalE]", "\\[FormalF]", "\\[FormalG]", "\\[FormalH]",
  "\\[FormalI]", "\\[FormalJ]", "\\[FormalK]", "\\[FormalL]",
  "\\[FormalM]", "\\[FormalN]", "\\[FormalO]", "\\[FormalP]",
  "\\[FormalQ]", "\\[FormalR]", "\\[FormalS]", "\\[FormalT]",
  "\\[FormalU]", "\\[FormalV]", "\\[FormalW]", "\\[FormalX]",
  "\\[FormalY]", "\\[FormalZ]", "\\[FormalCapitalA]",
  "\\[FormalCapitalB]", "\\[FormalCapitalC]", "\\[FormalCapitalD]",
  "\\[FormalCapitalE]", "\\[FormalCapitalF]", "\\[FormalCapitalG]",
  "\\[FormalCapitalH]", "\\[FormalCapitalI]", "\\[FormalCapitalJ]",
  "\\[FormalCapitalK]", "\\[FormalCapitalL]", "\\[FormalCapitalM]",
  "\\[FormalCapitalN]", "\\[FormalCapitalO]", "\\[FormalCapitalP]",
  "\\[FormalCapitalQ]", "\\[FormalCapitalR]", "\\[FormalCapitalS]",
  "\\[FormalCapitalT]", "\\[FormalCapitalU]", "\\[FormalCapitalV]",
  "\\[FormalCapitalW]", "\\[FormalCapitalX]", "\\[FormalCapitalY]",
  "\\[FormalCapitalZ]", "\\[FormalCapitalAlpha]",
  "\\[FormalCapitalBeta]", "\\[FormalCapitalGamma]",
  "\\[FormalCapitalDelta]", "\\[FormalCapitalEpsilon]",
  "\\[FormalCapitalZeta]", "\\[FormalCapitalEta]",
  "\\[FormalCapitalTheta]", "\\[FormalCapitalIota]",
  "\\[FormalCapitalKappa]", "\\[FormalCapitalLambda]",
  "\\[FormalCapitalMu]", "\\[FormalCapitalNu]", "\\[FormalCapitalXi]",
  "\\[FormalCapitalOmicron]", "\\[FormalCapitalPi]",
  "\\[FormalCapitalRho]", "\\[FormalCapitalSigma]",
  "\\[FormalCapitalTau]", "\\[FormalCapitalUpsilon]",
  "\\[FormalCapitalPhi]", "\\[FormalCapitalChi]",
  "\\[FormalCapitalPsi]", "\\[FormalCapitalOmega]", "\\[FormalAlpha]",
  "\\[FormalBeta]", "\\[FormalGamma]", "\\[FormalDelta]",
  "\\[FormalCurlyEpsilon]", "\\[FormalZeta]", "\\[FormalEta]",
  "\\[FormalTheta]", "\\[FormalIota]", "\\[FormalKappa]",
  "\\[FormalLambda]", "\\[FormalMu]", "\\[FormalNu]", "\\[FormalXi]", "\
\\[FormalOmicron]", "\\[FormalPi]", "\\[FormalRho]",
  "\\[FormalFinalSigma]", "\\[FormalSigma]", "\\[FormalTau]",
  "\\[FormalUpsilon]", "\\[FormalCurlyPhi]", "\\[FormalChi]",
  "\\[FormalPsi]", "\\[FormalOmega]"};

getStrippedContextNames[context_String] := Block[{$ContextPath = {context}},
  Names[RegularExpression[context <> "\$?[A-Z]\\w*"]]
];

getContextNames[context_String] := Block[{$ContextPath = {context}},
  StringJoin[context, #]& /@ Names[RegularExpression[context <> "\$?[A-Z]\\w*"]]
];

$builtInNames := Sort[
  Join[
    getStrippedContextNames["System`"],
    getContextNames["Developer`"],
    getContextNames["Internal`"]
  ]
];

(* This is just some non function words for performance testing the regex *)
$dictWords = DictionaryLookup[RegularExpression["[" <> StringJoin@CharacterRange["A", "M"] <> "].*"]];

PackageExport["createUnitTestWordList"]
createUnitTestWordList[outputDir_ /; DirectoryQ[outputDir]] :=
  {
    Export[FileNameJoin[{outputDir, "words.txt"}], $dictWords, "Table"],
    Export[FileNameJoin[{outputDir, "symbolNames.txt"}], $builtInNames, "Table"]
  };

PackageExport["namedCharacterQ"]
namedCharacterQ[c_Integer] := With[
  {
    str = ToString[FromCharacterCode[c], InputForm, CharacterEncoding -> "PrintableASCII"]
  },
  StringMatchQ[str, "\"\\[" ~~ __ ~~ "]\""]
];
namedCharacterQ[name_String] := namedCharacterQ[First@ToCharacterCode[name]];

PackageExport["codePointToCharacterName"]
codePointToCharacterName::inv = "Code point `` is not a valid named character.";
codePointToCharacterName[code_Integer] := With[
  {
    str = ToString[FromCharacterCode[code], InputForm, CharacterEncoding -> "PrintableASCII"]
  },
  If[TrueQ@StringMatchQ[str, "\"\\[" ~~ __ ~~ "]\""],
    StringReplace[str, "\"\\[" ~~ name__ ~~ "]\"" :> name],
    Message[codePointToCharacterName::inv, code];
    $Failed
  ]
];

PackageExport["createTrieRegex"]
createTrieRegex[words : {_String..}] := Utils`createReducedRegex[words];

PackageExport["namedCharactersList"]
namedCharactersList[] := Module[
  {
    range = Select[Range[16^^FFFF], namedCharacterQ[#]&]
  },
  codePointToCharacterName /@ range
];


PackageExport["buildJavaScriptTrieRegex"]
buildJavaScriptTrieRegex[] := buildJavaScriptTrieRegex[FileNameJoin[
  {
    $thisDirectory,
    "..",
    "..",
    "JSHighlighter",
    "lang-mma-TEMPLATE.js"
  }
]];

buildJavaScriptTrieRegex[highlighterTemplateJS_String /; FileExistsQ[highlighterTemplateJS]] := Module[
  {
    code = Import[highlighterTemplateJS, "String"],
    filename
  },
  code = StringReplace[code,
    {
      "$$KEYWORDS$$" -> createTrieRegex[$builtInNames],
      "$$NAMEDCHARACTERS$$" -> createTrieRegex[namedCharactersList[]]
    }
  ];
  filename = Export[FileNameJoin[
    {
      DirectoryName[highlighterTemplateJS],
      "lang-mma.js"
    }],
    code,
    "String"
  ] // FileBaseName;
  code = Import[
    FileNameJoin[{DirectoryName[highlighterTemplateJS], "performance-page-TEMPLATE.html"}],
    "String"
  ];
  code = StringReplace[
    code,
    {
      "$$SCRIPTNAME$$" -> filename <> ".js",
      "$$MMACODE$$" -> ExportString[Partition[Join[$builtInNames, $dictWords], 5], "Table"]
    }
  ];
  Export[
    FileNameJoin[{DirectoryName[highlighterTemplateJS], "performance-page-trie-regex.html"}],
    code,
    "String"
  ];
];

toAlternatives[words_List] := StringJoin[
  "(:?",
  StringReplace[StringRiffle[words, "|"], "$" -> "\\\\$"],
  ")"
];

PackageExport["buildJavaScriptAlternativeRegex"]
buildJavaScriptAlternativeRegex[] := buildJavaScriptAlternativeRegex[FileNameJoin[
  {
    $thisDirectory,
    "..",
    "..",
    "JSHighlighter",
    "lang-mma-TEMPLATE.js"
  }
]];

buildJavaScriptAlternativeRegex[highlighterTemplateJS_String /; FileExistsQ[highlighterTemplateJS]] := Module[
  {
    code = Import[highlighterTemplateJS, "String"],
    filename
  },
  code = StringReplace[code,
    {
      "$$KEYWORDS$$" -> toAlternatives[$builtInNames],
      "$$NAMEDCHARACTERS$$" -> toAlternatives[namedCharactersList[]]
    }
  ];
  filename = Export[FileNameJoin[
    {
      DirectoryName[highlighterTemplateJS],
      "lang-mma-alternative-regex.js"
    }],
    code,
    "String"
  ] // FileBaseName;
  code = Import[
    FileNameJoin[{DirectoryName[highlighterTemplateJS], "performance-page-TEMPLATE.html"}],
    "String"
  ];
  code = StringReplace[
    code,
    {
      "$$SCRIPTNAME$$" -> filename <> ".js",
      "$$MMACODE$$" -> ExportString[Partition[Join[$builtInNames, $dictWords], 5], "Table"]
    }
  ];
  Export[
    FileNameJoin[{DirectoryName[highlighterTemplateJS], "performance-page-alternative-regex.html"}],
    code,
    "String"
  ];
];

