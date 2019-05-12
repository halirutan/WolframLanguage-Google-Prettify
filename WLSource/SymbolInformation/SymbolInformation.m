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

PackageExport["createUnitTestWordList"]
createUnitTestWordList[outputDir_ /; DirectoryQ[outputDir]] := Module[
  {
    wrong = DictionaryLookup[RegularExpression["[" <> StringJoin@CharacterRange["A", "M"] <> "].*"]]
  },
  {
    Export[FileNameJoin[{outputDir, "words.txt"}], wrong, "Table"],
    Export[FileNameJoin[{outputDir, "symbolNames.txt"}], $builtInNames, "Table"]
  }
];

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

PackageExport["createNamedCharacterRegex"]
createNamedCharacterRegex[] := Module[
  {
    range = Select[Range[16^^FFFF], namedCharacterQ[#]&],
    chars
  },
  chars = codePointToCharacterName /@ range;
  Utils`createReducedRegex[chars]
];


PackageExport["buildJavaScriptRegexes"]
buildJavaScriptRegexes[] := buildJavaScriptRegexes[FileNameJoin[
  {
    $thisDirectory,
    "..",
    "..",
    "JSHighlighter",
    "lang-mma-TEMPLATE.js"
  }
]];

buildJavaScriptRegexes[highlighterTemplateJS_String /; FileExistsQ[highlighterTemplateJS]] := Module[
  {
    code = Import[highlighterTemplateJS, "String"]
  },
  code = StringReplace[code,
    {
      "$$KEYWORDS$$" -> createTrieRegex[$builtInNames],
      "$$NAMEDCHARACTERS$$" -> createNamedCharacterRegex[]
    }
  ];
  Export[FileNameJoin[
    {
      DirectoryName[highlighterTemplateJS],
      "lang-mma-" <> ToString[$VersionNumber] <> ".js"
    }],
    code,
    "String"
  ]
];
