(* ::Package:: *)

Attributes[symbols$270681] = {Temporary}
 
symbols$270681 = {aa2f3letEXTp4s4wl24, aa2f3letEXTp4s4wl32, 
     aa2fCreateList3let, aa2fCreateListSuffix3let, aa2fCreatePolynoms3let, 
     aa2fCreatePolynomsSuffix3let, aa2fCreateVariables3let, 
     aa2fFindTestChars3let, aa2fGiveMeAPolynom3let, aa2fInt32CreateList3let, 
     aa2fInt32MakeFreeWordUsingList3let, aa2fInt32Parikh, 
     aa2fInt32PickVariables3let, aa2fInt32SolveList3let, 
     aa2fInt32TestList3let, aa2fMakeFreeInfix3let, aa2fMakeFreeSuffix3let, 
     aa2fMakeFreeSuffixes3let, aa2fMakeFreeWord3let, aa2fMakeFreeWords3let, 
     aa2fParikh, aa2fPickVariables3let, aa2fSolveInBatches, 
     aa2fSolvePolynom3let, aa2fTestPolynom3let, 
     aaabANDrest3letLen4CasesReducedFactorFORM, 
     aaabANDrest3letLen4CasesReducedFORM, 
     aaabANDrest3letLen4CasesReducedPREF, 
     aaabANDrest3letLen4CasesReducedRule, 
     aaabTOxxxyANDrest3letLen4CasesReducedRule, 
     abacXabcaXabcbXabcdFactorFORM, abacXabcaXabcbXabcdFORM, 
     abacXabcaXabcbXabcdPREF, abacXabcaXabcbXabcdRule, allPerm3Let, 
     allPerm4let, createPermsAndMirsOfWord, createPermsAndMirsOfWordFlUnion, 
     deleteMirrorPermutations4let, deletePermutations4let, 
     exportMyDefinitions, hasNonNegativeComponentsThree, makeRowGraphics, 
     myStringTake, norm, normWithSign, pat, permutationsOFsc, s, 
     saveMyFunctionDefinitions, sc, sc3, sc3OdEv, sc3OdEvAdd, 
     sc3OdEvAddCumul, sc3OdEvAddCumulRest01, sc3OdEvAddIncr, 
     selectInneRxxFree, 
     selectNoThreeVec2uPLUSvNor2vPLUSuFromAdotBdoTpCCsDoTpDDs, 
     selectNoThreeVecFromAdotBdoTpCCsDoTpDDs, 
     showThreeVecAnBnAminusBfromAdotBdoTpCCsDoTpDDs, st, testA2, testA2Mir, 
     testA2MirThree, testA2MirVecStr, testA2MirVis, testA2MirVisThree, 
     testA2MirVisVecStr, testA2Three, testA2VecStr, testA2Vis, 
     testA2VisThree, testA2VisVecStr, testSuff, testSuffThree, 
     testSuffThreeVec, testSuffThreeVec2uPLUSvAnd2vPLUSu, testSuffVecStr, 
     testSuffVis, testSuffVisThree, testSuffVisVecStr, testThreeVec, 
     testThreeVec2uPLUSvAnd2vPLUSu, 
     testThreeVec2uPLUSvAnd2vPLUSuFromAdotBdoTpCCsDoTpDDs, 
     testThreeVecFromAdotBdoTpCCsDoTpDDs}
 
aa2f3letEXTp4s4wl24[w_String] := 
    Sort[Flatten[(aa2fInt32MakeFreeWordUsingList3let[
         StringJoin[StringReverse[#1], "BGJM"], 29] & ) /@ 
       aa2fInt32MakeFreeWordUsingList3let[StringJoin[StringReverse[w], 
         "AFHL"], 25]]]
 
aa2fInt32MakeFreeWordUsingList3let[str_String, startingPointer_Integer:4] := 
    Block[{myL, myV, myRes}, 
     myL = Union[aa2fInt32CreateList3let[str, startingPointer]]; 
      myV = aa2fInt32PickVariables3let[str]; 
      myRes = aa2fInt32TestList3let[myL, myV]; 
      intToCharAndNonCharVarsToCharVars = 
       myRes /. Flatten[{{0 -> "a", 1 -> "b", 2^16 -> "c"}, 
          nonCharVarsToCharVars}]; (StringReplace[str, #1] & ) /@ 
       intToCharAndNonCharVarsToCharVars]
 
aa2fInt32CreateList3let[str_String, startOfInfix_Integer:4] := 
    Block[{u, v, pu, pv, b, m, e, res = {}}, e = startOfInfix; 
      While[e <= StringLength[str], m = e - 1; b = m - 2; 
        While[b > 0, v = StringTake[str, {m, e}]; 
          u = StringTake[str, {b, m - 1}]; pv = aa2fInt32Parikh[v]; 
          pu = aa2fInt32Parikh[u]; AppendTo[res, pv - pu]; m = m - 1; 
          b = b - 2; ]; e = e + 1; ]; res]
 
aa2fInt32Parikh[x_List] := 
    (ReplaceAll[Flatten[{"a" -> 0, "b" -> 1, "c" -> 2^16, 
        charVarsToNonCharVars}]])[Plus @@ x]
 
aa2fInt32Parikh[x_String] := 
    (ReplaceAll[Flatten[{"a" -> 0, "b" -> 1, "c" -> 2^16, 
        charVarsToNonCharVars}]])[Plus @@ Characters[x]]
 
charVarsToNonCharVars = {"A" -> A, "B" -> B, "F" -> F, "G" -> G, "H" -> H, 
     "J" -> J, "L" -> L, "M" -> M, "P" -> P, "Q" -> Q, "R" -> R, "S" -> S, 
     "T" -> T, "U" -> U, "V" -> V, "W" -> W, "X" -> X, "Y" -> Y, "Z" -> Z, 
     "d" -> d, "e" -> e, "f" -> f, "g" -> g, "h" -> h, "i" -> i, "j" -> j, 
     "k" -> k, "l" -> l, "m" -> m, "n" -> n, "o" -> o, "q" -> q, "r" -> r, 
     "t" -> t, "u" -> u, "v" -> v, "w" -> w, "x" -> x, "y" -> y, "z" -> z}
 
aa2fInt32PickVariables3let[str_String] := 
    Block[{}, (ToExpression[#1] & ) /@ Complement[Union[Characters[str]], 
       Characters["abc"]]]
 
aa2fInt32TestList3let[linList_List, vars_List] := 
    Module[{replWithList, replLinList, res, pr, silmu = 3}, 
     replWithList = DeleteCases[({Take[vars, {1}][[1]] -> #1, 
           Catch[Do[If[(substLinList = linList /. Take[vars, {1}][[1]] -> 
                    #1)[[i]] == 0, Throw[0]], {i, 1, Length[linList]}]; 
             substLinList]} & ) /@ {0, 1, 2^16}, {_, 0}]; 
      If[Length[vars] == 1, Return[(Take[#1, 1][[1]] & ) /@ replWithList]]; 
      res = DeleteCases[({{#1[[1]]}, aa2fInt32SolveList3let[#1[[2]], 
            Take[vars, {2}][[1]]]} & ) /@ replWithList, {_, {}}]; 
      pr = (Flatten[#1, 2] & )[(Outer[List, #1[[1]], #1[[2]]] & ) /@ res]; 
      While[silmu <= Length[vars], replWithList = ({#1, linList /. #1} & ) /@ 
          pr; res = DeleteCases[({{#1[[1]]}, aa2fInt32SolveList3let[#1[[2]], 
              Take[vars, {silmu}][[1]]]} & ) /@ replWithList, {_, {}}]; 
        pr = (Flatten[#1, 2] & )[(Outer[List, #1[[1]], #1[[2]], 1, 1] & ) /@ 
           res]; pr = Flatten /@ pr; silmu = silmu + 1; ]; Return[pr]]
 
aa2fInt32SolveList3let[li_, var_, intList_:{0, 1, 65536}] := 
    Flatten[(Catch[Do[If[(li /. var -> #1)[[i]] == 0, Throw[{}]], 
          {i, 1, Length[li]}]; var -> #1] & ) /@ intList]
 
nonCharVarsToCharVars = {A -> "A", B -> "B", F -> "F", G -> "G", H -> "H", 
     J -> "J", L -> "L", M -> "M", P -> "P", Q -> "Q", R -> "R", S -> "S", 
     T -> "T", U -> "U", V -> "V", W -> "W", X -> "X", Y -> "Y", Z -> "Z", 
     d -> "d", e -> "e", f -> "f", g -> "g", h -> "h", i -> "i", j -> "j", 
     k -> "k", l -> "l", m -> "m", n -> "n", o -> "o", q -> "q", r -> "r", 
     t -> "t", u -> "u", v -> "v", w -> "w", x -> "x", y -> "y", z -> "z"}
 
aa2f3letEXTp4s4wl32[w_String] := 
    Sort[Flatten[(aa2fInt32MakeFreeWordUsingList3let[
         StringJoin[StringReverse[#1], "BGJM"], 37] & ) /@ 
       aa2fInt32MakeFreeWordUsingList3let[StringJoin[StringReverse[w], 
         "AFHL"], 33]]]
 
aa2fCreateList3let[str_String, startOfInfix_Integer:4] := 
    Module[{u, v, pu, pv, b, m, e, res = {}}, e = startOfInfix; 
      While[e <= StringLength[str], m = e - 1; b = m - 2; 
        While[b > 0, v = StringTake[str, {m, e}]; 
          u = StringTake[str, {b, m - 1}]; pv = aa2fParikh[v]; 
          pu = aa2fParikh[u]; AppendTo[res, pv - pu]; m = m - 1; 
          b = b - 2; ]; e = e + 1; ]; res]
 
aa2fParikh[x_List] := Plus @@ x
 
aa2fParikh[x_String] := Plus @@ Characters[x]
 
aa2fCreateListSuffix3let[str_String] := Module[{pu, pv, b, m, e, res = {}}, 
     e = StringLength[str]; m = e - 1; b = m - 2; 
      While[b > 0, pv = aa2fParikh[StringTake[str, {m, e}]]; 
        pu = aa2fParikh[StringTake[str, {b, m - 1}]]; AppendTo[res, pv - pu]; 
        m = m - 1; b = b - 2; ]; res]
 
aa2fCreatePolynoms3let[str_String, startOfInfix_Integer:4] := 
    Module[{u, v, pu, pv, b, m, e, res = {}}, e = startOfInfix; 
      While[e <= StringLength[str], m = e - 1; b = m - 2; 
        While[b > 0, v = StringTake[str, {m, e}]; 
          u = StringTake[str, {b, m - 1}]; pv = aa2fParikh[v]; 
          pu = aa2fParikh[u]; AppendTo[res, pv - pu]; m = m - 1; 
          b = b - 2; ]; e = e + 1; ]; Times @@ res]
 
aa2fCreatePolynoms3let[str_String, startOfInfix_Integer, 
     endOfInfix_Integer] := Module[{u, v, pu, pv, b, m, e, res = {}}, 
     e = startOfInfix; While[e <= StringLength[str], 
       If[e > endOfInfix + 1, If[OddQ[endOfInfix] == OddQ[e], 
           b = endOfInfix - 1; m = Ceiling[(e - b)/2] + b; , 
           b = endOfInfix; m = Ceiling[(e - b)/2] + b; ]; , 
         m = e - 1; b = m - 2; ]; While[b > 0, v = StringTake[str, {m, e}]; 
          u = StringTake[str, {b, m - 1}]; pv = aa2fParikh[v]; 
          pu = aa2fParikh[u]; AppendTo[res, pv - pu]; m = m - 1; 
          b = b - 2; ]; e = e + 1; ]; Times @@ res]
 
aa2fCreatePolynomsSuffix3let[str_String] := 
    Module[{pu, pv, b, m, e, res = {}}, e = StringLength[str]; m = e - 1; 
      b = m - 2; While[b > 0, pv = aa2fParikh[StringTake[str, {m, e}]]; 
        pu = aa2fParikh[StringTake[str, {b, m - 1}]]; AppendTo[res, pv - pu]; 
        m = m - 1; b = b - 2; ]; Times @@ res]
 
aa2fCreateVariables3let[variableCount_Integer, startingCode_Integer:65] := 
    Module[{}, FromCharacterCode[(Range[#1, #1 + variableCount - 1] & )[
       startingCode]]]
 
aa2fFindTestChars3let[var_, charList_] := Module[{pos, subList, res}, 
     pos = Flatten[Position[charList, var]]; If[pos == {}, 
       res = Characters["abc"]; , 
       subList = Flatten[Take[charList, {pos[[1]], pos[[1]]}]]; 
        res = (Extract[subList, #1] & ) /@ Flatten[
           (Position[subList, #1] & ) /@ Characters["abc"]]; 
        res = Flatten[Characters[res]]; ]; Return[res]]
 
aa2fGiveMeAPolynom3let[pref_String, inf_String, suff_String] := 
    Module[{str}, str = StringJoin[pref, inf, suff]; 
      aa2fCreatePolynoms3let[str, StringLength[pref] + 1, 
       StringLength[inf] + StringLength[pref]]]
 
aa2fMakeFreeInfix3let[pref_String, inf_String, suff_String] := 
    Module[{myP, myV, myRes}, myP = aa2fGiveMeAPolynom3let[pref, inf, suff]; 
      myV = StringJoin[Union[Characters[inf]]]; 
      myRes = aa2fTestPolynom3let[myP, myV, 1]; 
      (StringReplace[StringJoin[pref, inf, suff], #1] & ) /@ myRes]
 
aa2fMakeFreeInfix3let[pref_String, inf_String, suff_String, charList_List] := 
    Module[{myP, myV, myRes}, myP = aa2fGiveMeAPolynom3let[pref, inf, suff]; 
      myV = StringJoin[Union[Characters[inf]]]; 
      myRes = aa2fTestPolynom3let[myP, myV, 1, charList]; 
      (StringReplace[StringJoin[pref, inf, suff], #1] & ) /@ myRes]
 
aa2fMakeFreeInfix3let[pref_String, infLen_Integer, suff_String] := 
    Module[{myP, myV, myRes}, myV = aa2fCreateVariables3let[infLen, 256]; 
      myP = aa2fGiveMeAPolynom3let[pref, myV, suff]; 
      myRes = aa2fTestPolynom3let[myP, myV, 1]; 
      (StringReplace[StringJoin[pref, myV, suff], #1] & ) /@ myRes]
 
aa2fTestPolynom3let[polynGroup_, vars_String, outputType_Integer:1] := 
    Module[{polyList, res, pr, silmu = 3}, 
     polyList = DeleteCases[({StringTake[vars, {1}] -> #1, 
           polynGroup /. StringTake[vars, {1}] -> #1} & ) /@ 
         Characters["abc"], {_, 0}]; If[StringLength[vars] == 1, 
       Return[(Take[#1, 1] & ) /@ polyList]]; 
      res = DeleteCases[({{#1[[1]]}, aa2fSolvePolynom3let[#1[[2]], 
            StringTake[vars, {2}]]} & ) /@ polyList, {_, {}}]; 
      pr = (Flatten[#1, 2] & )[(Outer[List, #1[[1]], #1[[2]]] & ) /@ res]; 
      While[silmu <= StringLength[vars], 
       polyList = ({#1, polynGroup /. #1} & ) /@ pr; 
        res = DeleteCases[({{#1[[1]]}, aa2fSolvePolynom3let[#1[[2]], 
              StringTake[vars, {silmu}]]} & ) /@ polyList, {_, {}}]; 
        pr = (Flatten[#1, 2] & )[(Outer[List, #1[[1]], #1[[2]], 1, 1] & ) /@ 
           res]; pr = Flatten /@ pr; silmu = silmu + 1; ]; 
      If[outputType == 2, Return[(StringReplace[StringTake[vars, silmu - 1], 
           #1] & ) /@ pr], Return[pr]]]
 
aa2fTestPolynom3let[polynGroup_, vars_String, outputType_Integer:1, 
     charList_List] := Module[{polyList, res, pr, silmu = 3}, 
     polyList = DeleteCases[({StringTake[vars, {1}] -> #1, 
           polynGroup /. StringTake[vars, {1}] -> #1} & ) /@ 
         aa2fFindTestChars3let[StringTake[vars, {1}], charList], {_, 0}]; 
      If[StringLength[vars] == 1, Return[(Take[#1, 1] & ) /@ polyList]]; 
      res = DeleteCases[({{#1[[1]]}, aa2fSolvePolynom3let[#1[[2]], 
            StringTake[vars, {2}], aa2fFindTestChars3let[StringTake[vars, 
              {2}], charList]]} & ) /@ polyList, {_, {}}]; 
      pr = (Flatten[#1, 2] & )[(Outer[List, #1[[1]], #1[[2]]] & ) /@ res]; 
      While[silmu <= StringLength[vars], 
       polyList = ({#1, polynGroup /. #1} & ) /@ pr; 
        res = DeleteCases[({{#1[[1]]}, aa2fSolvePolynom3let[#1[[2]], 
              StringTake[vars, {silmu}], aa2fFindTestChars3let[StringTake[
                vars, {silmu}], charList]]} & ) /@ polyList, {_, {}}]; 
        pr = (Flatten[#1, 2] & )[(Outer[List, #1[[1]], #1[[2]], 1, 1] & ) /@ 
           res]; pr = Flatten /@ pr; silmu = silmu + 1; ]; 
      If[outputType == 2, Return[(StringReplace[StringTake[vars, silmu - 1], 
           #1] & ) /@ pr], Return[pr]]]
 
aa2fSolvePolynom3let[pol_, var_, charList_:{"a", "b", "c"}] := 
    Flatten[(If[(pol /. ToString[var] -> #1) =!= 0, ToString[var] -> #1, 
        {}] & ) /@ charList]
 
aa2fMakeFreeSuffix3let[str_String] := Module[{myP, myV, myRes}, 
     myP = aa2fCreatePolynomsSuffix3let[str]; 
      myV = aa2fPickVariables3let[str]; myRes = aa2fTestPolynom3let[myP, myV, 
        1]; (StringReplace[str, #1] & ) /@ myRes]
 
aa2fPickVariables3let[str_String] := Module[{}, 
     StringJoin[Complement[Union[Characters[str]], Characters["abc"]]]]
 
aa2fMakeFreeSuffixes3let[strs_List] := Module[{myP, myV, myRes, mixUp}, 
     myP = (aa2fCreatePolynomsSuffix3let[#1] & ) /@ strs; 
      myV = Flatten[Characters[(aa2fPickVariables3let[#1] & ) /@ strs]]; 
      myV = StringJoin[DeleteDuplicates[myV]]; mixUp = Times @@ myP; 
      myRes = aa2fTestPolynom3let[mixUp, myV, 1]; 
      (StringReplace[strs, #1] & ) /@ myRes]
 
aa2fMakeFreeWord3let[str_String] := Module[{myP, myV, myRes}, 
     myP = aa2fCreatePolynoms3let[str]; myV = aa2fPickVariables3let[str]; 
      myRes = aa2fTestPolynom3let[myP, myV, 1]; 
      (StringReplace[str, #1] & ) /@ myRes]
 
aa2fMakeFreeWord3let[str_String, charList_List] := 
    Module[{myP, myV, myRes}, myP = aa2fCreatePolynoms3let[str]; 
      myV = aa2fPickVariables3let[str]; myRes = aa2fTestPolynom3let[myP, myV, 
        1, charList]; (StringReplace[str, #1] & ) /@ myRes]
 
aa2fMakeFreeWords3let[{}, ___] := {}
 
aa2fMakeFreeWords3let[strs_List] := Module[{myP, myV, myRes, mixUp}, 
     myP = (aa2fCreatePolynoms3let[#1] & ) /@ strs; 
      myV = Flatten[Characters[(aa2fPickVariables3let[#1] & ) /@ strs]]; 
      myV = StringJoin[DeleteDuplicates[myV]]; mixUp = Times @@ myP; 
      myRes = aa2fTestPolynom3let[mixUp, myV, 1]; 
      (StringReplace[strs, #1] & ) /@ myRes]
 
aa2fMakeFreeWords3let[strs_List, charList_List] := 
    Module[{myP, myV, myRes, mixUp}, 
     myP = (aa2fCreatePolynoms3let[#1] & ) /@ strs; 
      myV = Flatten[Characters[(aa2fPickVariables3let[#1] & ) /@ strs]]; 
      myV = StringJoin[DeleteDuplicates[myV]]; mixUp = Times @@ myP; 
      myRes = aa2fTestPolynom3let[mixUp, myV, 1, charList]; 
      (StringReplace[strs, #1] & ) /@ myRes]
 
aa2fSolveInBatches[allWords_List, extBound_Integer, maxSteps_Integer:50000, 
     batchSize_Integer:20000, mainOutputDir_String:
      "D:\\ExtremeMathMmaComputations"] := 
    Module[{wordBatches, numBatches, globalExtendable = {}, 
      globalUndecided = {}, batchWords, batchResult, timeSpent, chunkDir}, 
     wordBatches = Partition[allWords, UpTo[batchSize]]; 
      numBatches = Length[wordBatches]; 
      Print["=================================================="]; 
      Print["  LAUNCHING BATCHED SOLVER (ROBUST VERSION)"]; 
      Print["  Total Words: ", Length[allWords]]; Print["  Batch Size:  ", 
       batchSize]; Print["  Total Chunks: ", numBatches]; 
      Print["=================================================="]; 
      If[ !DirectoryQ[mainOutputDir], CreateDirectory[mainOutputDir]]; 
      Do[Print["\n>>> PROCESSING CHUNK ", b, " OF ", numBatches, " (Size: ", 
         Length[wordBatches[[b]]], ") <<<"]; batchWords = wordBatches[[b]]; 
        chunkDir = FileNameJoin[{mainOutputDir, ToString[b]}]; 
        If[ !DirectoryQ[chunkDir], CreateDirectory[chunkDir]]; 
        {timeSpent, batchResult} = AbsoluteTiming[aa2fSolveRotational[
           batchWords, extBound, maxSteps, chunkDir]]; 
        Print["Chunk ", b, " complete in ", Round[timeSpent, 0.01], 
         " seconds."]; globalExtendable = Join[globalExtendable, 
          batchResult["Extendable"]]; globalUndecided = Join[globalUndecided, 
          batchResult["Undecided"]]; ClearSystemCache[]; 
        Clear[batchResult, batchWords]; , {b, 1, numBatches}]; 
      Print["\n=================================================="]; 
      Print["  ALL BATCHES COMPLETE"]; Print["  Global Extendable Found: ", 
       Length[globalExtendable]]; Print["  Global Remaining Undecided: ", 
       Length[globalUndecided]]; 
      Print["=================================================="]; 
      Export[FileNameJoin[{mainOutputDir, "GLOBAL_EXTENDABLE_SUMMARY.txt"}], 
       globalExtendable, "Table"]; Export[FileNameJoin[
        {mainOutputDir, "GLOBAL_UNDECIDED_SUMMARY.txt"}], globalUndecided, 
       "Table"]; Association["GlobalExtendable" -> globalExtendable, 
       "GlobalUndecided" -> globalUndecided]]
 
aaabANDrest3letLen4CasesReducedFactorFORM[x_String, factorPointer_] := 
    StringReplace[x, aaabANDrest3letLen4CasesReducedRule[
      Characters[StringTake[x, {factorPointer, factorPointer + 3}]]]]
 
aaabANDrest3letLen4CasesReducedRule[{a_, a_, a_, b_}] := 
    {a -> "a", b -> "b", Complement[{"a", "b", "c"}, {a, b}][[1]] -> "c"}
 
aaabANDrest3letLen4CasesReducedRule[{a_, a_, b_, a_}] := 
    {a -> "a", b -> "b", Complement[{"a", "b", "c"}, {a, b}][[1]] -> "c"}
 
aaabANDrest3letLen4CasesReducedRule[{a_, a_, b_, b_}] := 
    {a -> "a", b -> "b", Complement[{"a", "b", "c"}, {a, b}][[1]] -> "c"}
 
aaabANDrest3letLen4CasesReducedRule[{a_, a_, b_, c_}] := 
    {a -> "a", b -> "b", c -> "c"} /; Sort[{a, b, c}] === {"a", "b", "c"}
 
aaabANDrest3letLen4CasesReducedRule[{a_, b_, a_, a_}] := 
    {a -> "a", b -> "b", Complement[{"a", "b", "c"}, {a, b}][[1]] -> "c"}
 
aaabANDrest3letLen4CasesReducedRule[{a_, b_, a_, c_}] := 
    {a -> "a", b -> "b", c -> "c"} /; Sort[{a, b, c}] === {"a", "b", "c"}
 
aaabANDrest3letLen4CasesReducedRule[{a_, b_, b_, b_}] := 
    {a -> "a", b -> "b", Complement[{"a", "b", "c"}, {a, b}][[1]] -> "c"}
 
aaabANDrest3letLen4CasesReducedRule[{a_, b_, b_, c_}] := 
    {a -> "a", b -> "b", c -> "c"} /; Sort[{a, b, c}] === {"a", "b", "c"}
 
aaabANDrest3letLen4CasesReducedRule[{a_, b_, c_, a_}] := 
    {a -> "a", b -> "b", c -> "c"} /; Sort[{a, b, c}] === {"a", "b", "c"}
 
aaabANDrest3letLen4CasesReducedRule[{a_, b_, c_, b_}] := 
    {a -> "a", b -> "b", c -> "c"} /; Sort[{a, b, c}] === {"a", "b", "c"}
 
aaabANDrest3letLen4CasesReducedRule[{a_, b_, c_, c_}] := 
    {a -> "a", b -> "b", c -> "c"} /; Sort[{a, b, c}] === {"a", "b", "c"}
 
aaabANDrest3letLen4CasesReducedFORM[{}] := {}
 
aaabANDrest3letLen4CasesReducedFORM[x_String] := 
    StringReplace[x, aaabANDrest3letLen4CasesReducedPREF[
      Characters[StringTake[x, 4]]]]
 
aaabANDrest3letLen4CasesReducedPREF[{a_, a_, a_, b_}] := 
    {a -> "a", b -> "b", Complement[{"a", "b", "c"}, {a, b}][[1]] -> "c"}
 
aaabANDrest3letLen4CasesReducedPREF[{a_, a_, b_, a_}] := 
    {a -> "a", b -> "b", Complement[{"a", "b", "c"}, {a, b}][[1]] -> "c"}
 
aaabANDrest3letLen4CasesReducedPREF[{a_, a_, b_, b_}] := 
    {a -> "a", b -> "b", Complement[{"a", "b", "c"}, {a, b}][[1]] -> "c"}
 
aaabANDrest3letLen4CasesReducedPREF[{a_, a_, b_, c_}] := 
    {a -> "a", b -> "b", c -> "c"} /; Sort[{a, b, c}] === {"a", "b", "c"}
 
aaabANDrest3letLen4CasesReducedPREF[{a_, b_, a_, a_}] := 
    {a -> "a", b -> "b", Complement[{"a", "b", "c"}, {a, b}][[1]] -> "c"}
 
aaabANDrest3letLen4CasesReducedPREF[{a_, b_, a_, c_}] := 
    {a -> "a", b -> "b", c -> "c"} /; Sort[{a, b, c}] === {"a", "b", "c"}
 
aaabANDrest3letLen4CasesReducedPREF[{a_, b_, b_, b_}] := 
    {a -> "a", b -> "b", Complement[{"a", "b", "c"}, {a, b}][[1]] -> "c"}
 
aaabANDrest3letLen4CasesReducedPREF[{a_, b_, b_, c_}] := 
    {a -> "a", b -> "b", c -> "c"} /; Sort[{a, b, c}] === {"a", "b", "c"}
 
aaabANDrest3letLen4CasesReducedPREF[{a_, b_, c_, a_}] := 
    {a -> "a", b -> "b", c -> "c"} /; Sort[{a, b, c}] === {"a", "b", "c"}
 
aaabANDrest3letLen4CasesReducedPREF[{a_, b_, c_, b_}] := 
    {a -> "a", b -> "b", c -> "c"} /; Sort[{a, b, c}] === {"a", "b", "c"}
 
aaabANDrest3letLen4CasesReducedPREF[{a_, b_, c_, c_}] := 
    {a -> "a", b -> "b", c -> "c"} /; Sort[{a, b, c}] === {"a", "b", "c"}
 
aaabTOxxxyANDrest3letLen4CasesReducedRule[{x_, x_, x_, y_}] := 
    {x -> "a", y -> "b", Complement[{"a", "b", "c"}, {x, y}][[1]] -> "c"}
 
aaabTOxxxyANDrest3letLen4CasesReducedRule[{x_, x_, y_, x_}] := 
    {"a" -> x, "b" -> y, "c" -> Complement[{"a", "b", "c"}, {x, y}][[1]]}
 
aaabTOxxxyANDrest3letLen4CasesReducedRule[{x_, x_, y_, y_}] := 
    {"a" -> x, "b" -> y, "c" -> Complement[{"a", "b", "c"}, {x, y}][[1]]}
 
aaabTOxxxyANDrest3letLen4CasesReducedRule[{x_, x_, y_, z_}] := 
    {"a" -> x, "b" -> y, "c" -> z} /; Sort[{x, y, z}] === {"a", "b", "c"}
 
aaabTOxxxyANDrest3letLen4CasesReducedRule[{x_, y_, x_, x_}] := 
    {"a" -> x, "b" -> y, "c" -> Complement[{"a", "b", "c"}, {x, y}][[1]]}
 
aaabTOxxxyANDrest3letLen4CasesReducedRule[{x_, y_, x_, z_}] := 
    {"a" -> x, "b" -> y, "c" -> z} /; Sort[{x, y, z}] === {"a", "b", "c"}
 
aaabTOxxxyANDrest3letLen4CasesReducedRule[{x_, y_, y_, y_}] := 
    {"a" -> x, "b" -> y, "c" -> Complement[{"a", "b", "c"}, {x, y}][[1]]}
 
aaabTOxxxyANDrest3letLen4CasesReducedRule[{x_, y_, y_, z_}] := 
    {"a" -> x, "b" -> y, "c" -> z} /; Sort[{x, y, z}] === {"a", "b", "c"}
 
aaabTOxxxyANDrest3letLen4CasesReducedRule[{x_, y_, z_, x_}] := 
    {"a" -> x, "b" -> y, "c" -> z} /; Sort[{x, y, z}] === {"a", "b", "c"}
 
aaabTOxxxyANDrest3letLen4CasesReducedRule[{x_, y_, z_, y_}] := 
    {"a" -> x, "b" -> y, "c" -> z} /; Sort[{x, y, z}] === {"a", "b", "c"}
 
aaabTOxxxyANDrest3letLen4CasesReducedRule[{x_, y_, z_, z_}] := 
    {"a" -> x, "b" -> y, "c" -> z} /; Sort[{x, y, z}] === {"a", "b", "c"}
 
abacXabcaXabcbXabcdFactorFORM[x_String, factorPointer_] := 
    StringReplace[x, abacXabcaXabcbXabcdRule[
      Characters[StringTake[x, {factorPointer, factorPointer + 3}]]]]
 
abacXabcaXabcbXabcdRule[{a_, b_, a_, c_}] := {a -> "a", b -> "b", c -> "c", 
     Complement[{"a", "b", "c", "d"}, {a, b, c}][[1]] -> "d"}
 
abacXabcaXabcbXabcdRule[{a_, b_, c_, a_}] := {a -> "a", b -> "b", c -> "c", 
     Complement[{"a", "b", "c", "d"}, {a, b, c}][[1]] -> "d"}
 
abacXabcaXabcbXabcdRule[{a_, b_, c_, b_}] := {a -> "a", b -> "b", c -> "c", 
     Complement[{"a", "b", "c", "d"}, {a, b, c}][[1]] -> "d"}
 
abacXabcaXabcbXabcdRule[{a_, b_, c_, d_}] := 
    {a -> "a", b -> "b", c -> "c", d -> "d"} /; Sort[{a, b, c, d}] === 
      {"a", "b", "c", "d"}
 
abacXabcaXabcbXabcdFORM[x_String] := StringReplace[x, 
     abacXabcaXabcbXabcdPREF[Characters[StringTake[x, 4]]]]
 
abacXabcaXabcbXabcdPREF[{a_, b_, a_, c_}] := {a -> "a", b -> "b", c -> "c", 
     Complement[{"a", "b", "c", "d"}, {a, b, c}][[1]] -> "d"}
 
abacXabcaXabcbXabcdPREF[{a_, b_, c_, a_}] := {a -> "a", b -> "b", c -> "c", 
     Complement[{"a", "b", "c", "d"}, {a, b, c}][[1]] -> "d"}
 
abacXabcaXabcbXabcdPREF[{a_, b_, c_, b_}] := {a -> "a", b -> "b", c -> "c", 
     Complement[{"a", "b", "c", "d"}, {a, b, c}][[1]] -> "d"}
 
abacXabcaXabcbXabcdPREF[{a_, b_, c_, d_}] := 
    {a -> "a", b -> "b", c -> "c", d -> "d"} /; Sort[{a, b, c, d}] === 
      {"a", "b", "c", "d"}
 
allPerm3Let[x_String] := 
    (StringReplace[x, Thread[{"a", "b", "c"} -> #1]] & ) /@ 
     Permutations[{"a", "b", "c"}]
 
allPerm4let[x_String] := 
    (StringReplace[x, Thread[{"a", "b", "c", "d"} -> #1]] & ) /@ 
     Permutations[{"a", "b", "c", "d"}]
 
createPermsAndMirsOfWord[w_String] := 
    Block[{myList = (StringReplace[w, #1] & ) /@ permsRules}, 
     {myList, StringReverse /@ myList}]
 
permsRules = {{"a" -> "a", "b" -> "b", "c" -> "c"}, 
     {"a" -> "a", "b" -> "c", "c" -> "b"}, {"a" -> "b", "b" -> "a", 
      "c" -> "c"}, {"a" -> "b", "b" -> "c", "c" -> "a"}, 
     {"a" -> "c", "b" -> "a", "c" -> "b"}, {"a" -> "c", "b" -> "b", 
      "c" -> "a"}}
 
createPermsAndMirsOfWordFlUnion[w_String] := 
    Union[Flatten[Block[{myList = (StringReplace[w, #1] & ) /@ permsRules}, 
       {myList, StringReverse /@ myList}]]]
 
deleteMirrorPermutations4let[{x_List, y_List}] := 
    {{x, y[[1]]}, Complement[Rest[y], allPerm4let[StringReverse[y[[1]]]]]}
 
deletePermutations4let[{x_List, y_List}] := {{x, y[[1]]}, 
     Complement[Rest[y], allPerm4let[y[[1]]]]}
 
exportMyDefinitions[file_String:"myDefinitions.txt"] := 
    Module[{symbols, text}, 
     symbols = SortBy[Select[ToExpression /@ Names["Global`*"], 
         Head[#1] === Symbol && (OwnValues[#1] =!= {} || DownValues[#1] =!= 
             {} || UpValues[#1] =!= {} || SubValues[#1] =!= {}) & ], 
        SymbolName]; text = StringRiffle[
        (ToString[Definition[#1], InputForm] & ) /@ symbols, "\n\n"]; 
      Export[file, text, "Text"]]
 
hasNonNegativeComponentsThree[(x_Plus) | (x_Times) | (x_String)] := 
    (x /. {"a" -> 1, "b" -> 0, "c" -> 0, "" -> 0}) >= 0 && 
     (x /. {"a" -> 0, "b" -> 1, "c" -> 0, "" -> 0}) >= 0 && 
     (x /. {"a" -> 0, "b" -> 0, "c" -> 1, "" -> 0}) >= 0
 
hasNonNegativeComponentsThree[x_List] := And @@ (#1 >= 0 & ) /@ x
 
makeRowGraphics[row_, y_] := Module[{chars = Characters[row], x = 1, 
      pieces = {}}, Do[If[chars[[i]] === " ", x += spaceStep, 
        AppendTo[pieces, {EdgeForm[GrayLevel[0.65]], colorRules[chars[[i]]], 
           Disk[{x, y}, diskRadius], Black, Text[Style[chars[[i]], 14], 
            {x, y}]}]; x += letterStep], {i, Length[chars]}]; pieces]
 
chars = {"a", "b", "c", "a", "c", "d", "c", "b", "c", "d", "c", "a", "d", 
     "c", "d", "b", "d", "a", "b", "a", "c", "a", "b", "a", "d", "b", "a", 
     "b", "c", "b", "d", "b", "c", "b", "a", "c", "b", "c", "d", "c", "a", 
     "c", "b", "a", "b", "d", "a", "b", "a", "c", "a", "d", "c", "b", "c", 
     "d", "c", "a", "c", "d", "b", "c", "b", "a", "c", "b", "c", "d", "c", 
     "a", "c", "d", "c", "b", "d", "c", "d", "a", "d", "b", "d", "c", "b", 
     "c", "a"}
 
spaceStep = 0.45
 
colorRules = <|"a" -> RGBColor[1., 0.35, 0.35], 
     "b" -> RGBColor[0.25, 1., 0.25], "c" -> RGBColor[1., 1., 0.15], 
     "d" -> RGBColor[0.35, 0.35, 1.]|>
 
diskRadius = 0.45
 
letterStep = 1.
 
myStringTake[x_String, {i_Integer, j_Integer}] := "" /; i > j
 
myStringTake[x_String, {i_Integer, j_Integer}] := "" /; i < 1
 
myStringTake[x_String, {0, 0}] := ""
 
myStringTake[x_String, {i_Integer, j_Integer}] := StringTake[x, {i, j}]
 
norm[0] = 0
 
norm[(x_Plus) | (x_Times) | (x_String)] := 
    Abs[x /. {"a" -> 1, "b" -> 1, "c" -> 1}]
 
norm[x_List] := Abs[Plus @@ x]
 
normWithSign[0] = 0
 
normWithSign[(x_Plus) | (x_Times) | (x_String)] := 
    x /. {"a" -> 1, "b" -> 1, "c" -> 1}
 
normWithSign[x_List] := Plus @@ x
 
pat[pv_] := StringExpression @@ PadRight[{}, Total[pv], _]
 
permutationsOFsc[fct_] := Permutations[{StringCount[fct, "a"], 
      StringCount[fct, "b"], StringCount[fct, "c"]}]
 
s[x_String] := Plus @@ Characters[x]
 
s[x_List] := Plus @@ x
 
saveMyFunctionDefinitions[file_String:"myFunctionDefinitions.wl"] := 
    Module[{symbols}, symbols = SortBy[Select[ToExpression /@ 
          Names["Global`*"], Head[#1] === Symbol && DownValues[#1] =!= 
            {} & ], SymbolName]; Save[file, symbols]]
 
sc[fct_] := {StringCount[fct, "a"], StringCount[fct, "b"], 
     StringCount[fct, "c"]}
 
sc3[s_String] := {StringCount[s, "a"], StringCount[s, "b"], 
     StringCount[s, "c"]}
 
sc3OdEv[s_String] := {EvenQ[StringCount[s, "a"]], EvenQ[StringCount[s, "b"]], 
     EvenQ[StringCount[s, "c"]]}
 
sc3OdEvAdd[tv_List, s_String] := MapThread[Xnor, {tv, sc3OdEv[s]}]
 
sc3OdEvAddCumul[tv_List, s_String, partitionStep_Integer] := 
    FoldList[sc3OdEvAdd, tv, StringPartition[s, partitionStep]]
 
sc3OdEvAddCumulRest01[tv_List, s_String, partitionStep_Integer] := 
    Rest[sc3OdEvAddCumul[tv, s, partitionStep] /. {True -> 0, False -> 1}]
 
sc3OdEvAddIncr[tv_List, s_String, pos_Integer, step_Integer:0] := 
    sc3OdEvAdd[tv, StringTake[s, {pos, pos + step}]]
 
selectInneRxxFree[str_String] := 
    If[StringFreeQ[str, y_~~x_~~x_~~z_ /; y != x && z != x], str, {}]
 
selectNoThreeVec2uPLUSvNor2vPLUSuFromAdotBdoTpCCsDoTpDDs[x_String, 
     "vecA&B&AminusB"] := 
    If[testThreeVec2uPLUSvAnd2vPLUSuFromAdotBdoTpCCsDoTpDDs[x, 
      "vecA&B&AminusB"], x, {}]
 
testThreeVec2uPLUSvAnd2vPLUSuFromAdotBdoTpCCsDoTpDDs[x_String, 
     "vecA&B&AminusB"] := Block[{rules = toRulesFromAdotBdoTpCCsDoTpDDs[x], 
      spList, vecA, vecB}, spList = StringReplace[{"CspD", "DspC"}, rules]; 
      vecA = s[StringReplace["A", rules]]; 
      vecB = s[StringReplace["B", rules]]; vecAminusB = 
       s[StringReplace["A", rules]] - s[StringReplace["B", rules]]; 
      testThreeVec2uPLUSvAnd2vPLUSu[spList[[1]], vecAminusB] && 
       testThreeVec2uPLUSvAnd2vPLUSu[spList[[2]], vecAminusB] && 
       testThreeVec2uPLUSvAnd2vPLUSu[spList[[1]], vecA] && 
       testThreeVec2uPLUSvAnd2vPLUSu[spList[[2]], vecA] && 
       testThreeVec2uPLUSvAnd2vPLUSu[spList[[1]], vecB] && 
       testThreeVec2uPLUSvAnd2vPLUSu[spList[[2]], vecB]]
 
testThreeVec2uPLUSvAnd2vPLUSu[x_String, (vec_Plus) | (vec_Times) | 
      (vec_String)] := If[StringLength[x] < Ceiling[norm[vec]/2], 
     "Too short string", Block[{sl = StringLength[x], 
       vecFreePrefLen = Ceiling[norm[vec]/2], i = 0, res}, 
      While[vecFreePrefLen + i <= sl && (res = 
          testSuffThreeVec2uPLUSvAnd2vPLUSu[StringTake[x, vecFreePrefLen + 
             i], vec]), i++]; (vecPrefLen = vecFreePrefLen + i; res)]]
 
testSuffThreeVec2uPLUSvAnd2vPLUSu[x_String, (vec_Plus) | (vec_Times) | 
      (vec_String)] := Block[{sl = StringLength[x], i, j = 0, res = True, 
       nrm = norm[vec]}, i = nrm - 2*j; While[2*j <= norm[vec] && 
         (res =  !(Expand[s[myStringTake[x, {sl - i - j + 1, sl - j}]] + 2*
                s[myStringTake[x, {sl - j + 1, sl}]]] === vec || 
            Expand[2*s[myStringTake[x, {sl - i - j + 1, sl - i}]] + s[
                myStringTake[x, {sl - i + 1, sl}]]] === vec)), 
        j++; i = nrm - 2*j]; res] /; hasNonNegativeComponentsThree[vec] && 
      norm[vec] > 0
 
testSuffThreeVec2uPLUSvAnd2vPLUSu[x_String, (vec_Plus) | (vec_Times) | 
      (vec_String)] := True
 
selectNoThreeVecFromAdotBdoTpCCsDoTpDDs[x_String, "vecA&B&AminusB"] := 
    If[testThreeVecFromAdotBdoTpCCsDoTpDDs[x, "vecA&B&AminusB"], x, {}]
 
testThreeVecFromAdotBdoTpCCsDoTpDDs[x_String, "vecA&B&AminusB"] := 
    Block[{rules = toRulesFromAdotBdoTpCCsDoTpDDs[x], spList, vecA, vecB}, 
     spList = StringReplace[{"CspD", "DspC"}, rules]; 
      vecA = s[StringReplace["A", rules]]; 
      vecB = s[StringReplace["B", rules]]; vecAminusB = 
       s[StringReplace["A", rules]] - s[StringReplace["B", rules]]; 
      testThreeVec[spList[[1]], vecAminusB] && testThreeVec[spList[[2]], 
        vecAminusB] && testThreeVec[spList[[1]], vecA] && 
       testThreeVec[spList[[2]], vecA] && testThreeVec[spList[[1]], vecB] && 
       testThreeVec[spList[[2]], vecB]]
 
testThreeVec[x_String, (vec_Plus) | (vec_Times) | (vec_String)] := 
    If[StringLength[x] < norm[vec], "Too short string", 
     Block[{sl = StringLength[x], vecFreePrefLen = Max[norm[vec], 2], i = 0, 
       res}, While[vecFreePrefLen + i <= sl && (res = testSuffThreeVec[
           StringTake[x, vecFreePrefLen + i], vec]), i++]; 
       (vecPrefLen = vecFreePrefLen + i; res)]]
 
testSuffThreeVec[x_String, (vec_Plus) | (vec_Times) | (vec_String)] := 
    Block[{sl = StringLength[x], i = 0, res = True}, 
      While[i < Floor[sl/2] && (res = 
           !(s[StringTake[x, {sl - 1 - 2*i, sl - 1 - i}]] === 
             s[StringTake[x, {sl - i, sl}]] - vec || 
            s[StringTake[x, {sl - 1 - 2*i, sl - 1 - i}]] === 
             s[StringTake[x, {sl - i, sl}]] + vec)), i++]; res] /; 
     norm[vec] === 0
 
testSuffThreeVec[x_String, 0] := Block[{sl = StringLength[x], i = 0, 
      res = True}, While[i < Floor[sl/2] && 
        (res =  !s[StringTake[x, {sl - 1 - 2*i, sl - 1 - i}]] === 
           s[StringTake[x, {sl - i, sl}]]), i++]; res]
 
testSuffThreeVec[x_String, (vec_Plus) | (vec_Times) | (vec_String)] := 
    Block[{sl = StringLength[x], i = 0, res = True, nws = normWithSign[vec], 
      nrm = norm[vec]}, If[nws < 0, If[s[StringTake[x, -nrm]] === -vec, 
         res = False; Return[res]]; While[i < Floor[(sl - nrm)/2] && 
          (res =  !(s[StringTake[x, {sl - 1 - 2*i - nrm, sl - 1 - i}]] === 
              s[StringTake[x, {sl - i, sl}]] - vec || 
             s[StringTake[x, {sl - 1 - 2*i - nrm, sl - 1 - i - nrm}]] === 
              s[StringTake[x, {sl - i - nrm, sl}]] + vec)), i++], 
       If[s[StringTake[x, -nrm]] === vec, res = False; Return[res]]; 
        While[i < Floor[(sl - nrm)/2] && (res = 
            !(s[StringTake[x, {sl - 1 - 2*i - nrm, sl - 1 - i - nrm}]] === 
              s[StringTake[x, {sl - i - nrm, sl}]] - vec || 
             s[StringTake[x, {sl - 1 - 2*i - nrm, sl - 1 - i}]] === 
              s[StringTake[x, {sl - i, sl}]] + vec)), i++]]; res]
 
showThreeVecAnBnAminusBfromAdotBdoTpCCsDoTpDDs[x_String, "vecA&B&AminusB"] := 
    Block[{rules = toRulesFromAdotBdoTpCCsDoTpDDs[x], spList, vecA, vecB}, 
     {vecA = s[StringReplace["A", rules]], 
      vecB = s[StringReplace["B", rules]], vecAminusB = 
       s[StringReplace["A", rules]] - s[StringReplace["B", rules]]}]
 
st[x_String, m_Integer, n_Integer] := StringTake[x, {m, n}]
 
testA2[x_, a2FreePrefLen_:2] := If[StringLength[x] < 2, "Too short string", 
     Module[{sl = StringLength[x], i = 0, res}, 
      While[a2FreePrefLen + i <= sl && (res = testSuff[StringTake[x, 
            a2FreePrefLen + i]]), i++]; (asp = a2FreePrefLen + i; res)]]
 
testSuff[x_] := Module[{sl = StringLength[x], i = 0, res = True}, 
     While[i < Floor[sl/2] && (res = 
          !s[StringTake[x, {sl - 1 - 2*i, sl - 1 - i}]] === 
           s[StringTake[x, {sl - i, sl}]]), i++]; res]
 
testA2Mir[x_, a2FreePrefLen_:2] := testA2[StringReverse[x], a2FreePrefLen]
 
testA2MirThree[x_, a2FreePrefLen_:4] := testA2Three[StringReverse[x], 
     a2FreePrefLen]
 
testA2Three[x_, a2FreePrefLen_:4] := If[StringLength[x] < 4, 
     "Too short string", Block[{sl = StringLength[x], i = 0, res}, 
      While[a2FreePrefLen + i <= sl && (res = testSuffThree[
           StringTake[x, a2FreePrefLen + i]]), i++]; 
       (asp = a2FreePrefLen + i; res)]]
 
testSuffThree[x_] := Block[{sl = StringLength[x], i = 1, res = True}, 
     While[i < Floor[sl/2] && (res = 
          !s[StringTake[x, {sl - 1 - 2*i, sl - 1 - i}]] === 
           s[StringTake[x, {sl - i, sl}]]), i++]; res]
 
testA2MirVecStr[x_, a2FreePrefLen_:2] := testA2VecStr[Reverse[x], 
     a2FreePrefLen]
 
testA2VecStr[x_, a2FreePrefLen_:2] := If[Length[x] < 2, 
     "Too short string of vetors", Module[{sl = Length[x], i = 0, res}, 
      While[a2FreePrefLen + i <= sl && (res = testSuffVecStr[
           Take[x, a2FreePrefLen + i]]), i++]; (asp = a2FreePrefLen + i; 
        res)]]
 
testSuffVecStr[x_] := Module[{sl = Length[x], i = 0, res = True}, 
     While[i < Floor[sl/2] && (res = 
          !s[Take[x, {sl - 1 - 2*i, sl - 1 - i}]] === 
           s[Take[x, {sl - i, sl}]]), i++]; res]
 
testA2MirVis[x_, a2FreePrefLen_:2] := testA2Vis[StringReverse[x], 
     a2FreePrefLen]
 
testA2Vis[x_, a2FreePrefLen_:2] := If[StringLength[x] < 2, 
     "Too short string", Module[{sl = StringLength[x], i = 0, res}, 
      While[a2FreePrefLen + i <= sl, 
        If[(res = testSuffVis[StringTake[x, a2FreePrefLen + i]]) === True, 
          True, Print[res]]; i++]; "End"]]
 
testSuffVis[x_] := Module[{sl = StringLength[x], i = 0, res}, 
     While[i < Floor[sl/2] && (res = 
          !s[StringTake[x, {sl - 1 - 2*i, sl - 1 - i}]] === 
           s[StringTake[x, {sl - i, sl}]]), i++]; 
      If[res, True, {StringTake[x, {sl - 1 - 2*i, sl - 1 - i}], 
        StringTake[x, {sl - i, sl}], 2*(i + 1)}]]
 
testA2MirVisThree[x_, a2FreePrefLen_:4] := testA2VisThree[StringReverse[x], 
     a2FreePrefLen]
 
testA2VisThree[x_, a2FreePrefLen_:4] := If[StringLength[x] < 4, 
     "Too short string", Block[{sl = StringLength[x], i = 0, res}, 
      While[a2FreePrefLen + i <= sl, 
        If[(res = testSuffVisThree[StringTake[x, a2FreePrefLen + i]]) === 
           True, True, Print[res]]; i++]; "End"]]
 
testSuffVisThree[x_] := Block[{sl = StringLength[x], i = 1, res}, 
     While[i < Floor[sl/2] && (res = 
          !s[StringTake[x, {sl - 1 - 2*i, sl - 1 - i}]] === 
           s[StringTake[x, {sl - i, sl}]]), i++]; 
      If[res, True, {StringTake[x, {sl - 1 - 2*i, sl - 1 - i}], 
        StringTake[x, {sl - i, sl}], 2*(i + 1)}]]
 
testA2MirVisVecStr[x_, a2FreePrefLen_:2] := testA2VisVecStr[Reverse[x], 
     a2FreePrefLen]
 
testA2VisVecStr[x_, a2FreePrefLen_:2] := If[Length[x] < 2, 
     "Too short string of vetors", Module[{sl = Length[x], i = 0, res}, 
      While[a2FreePrefLen + i <= sl, 
        If[(res = testSuffVisVecStr[Take[x, a2FreePrefLen + i]]) === True, 
          True, Print[res]]; i++]; "End"]]
 
testSuffVisVecStr[x_] := Module[{sl = Length[x], i = 0, res}, 
     While[i < Floor[sl/2] && (res = 
          !s[Take[x, {sl - 1 - 2*i, sl - 1 - i}]] === 
           s[Take[x, {sl - i, sl}]]), i++]; If[res, True, 
       {Take[x, {sl - 1 - 2*i, sl - 1 - i}], Take[x, {sl - i, sl}], 
        2*(i + 1)}]]


(* :Title: vmmPolyTests345_release.m *)

(* :Context: vmmPolyTests` *)

(* :Author: 
	Ville Mattila
	3 and 5 letter case by Veikko Ker\[ADoubleDot]nen 
*)

(* :Summary: 
	Functions for creating abelian square-free strings.
	Functions are based on polynomial inequalities.
*)

(* :Copyright: 
	\[Copyright] 2001, 2002, 2012 by Ville Mattila (vmm@iki.fi)
	\[Copyright] 2011, 2012, 2013, 2014 by Veikko Ker\[ADoubleDot]nen (veikko.keranen@gmail.com)
*)

(* :Package Version: 0.3 *)

(* :Mathematica Version: 8.0.1.0 *)

(* :History:
	0.3 Possibility to search for multiple words using common variables
	0.2 Veikko's additions for 3 and 5 letter cases
	0.1 First package version
*)

(* :Keywords: 
	abelian square-free, a-2-free, polynomial inequalities, 
	avoidable regularities in strings, avoidable patterns in strings
*)

(* :Sources: 
*)
(* :Warnings:
	Long words consisting of many variables will take long to create.
	Execution time will increase exponentially with longer words. 
*)

(* :Limitations:
	If the name of the function does not imply which alphabet it is using, it is using four letter alphabet!
*)

(* :Discussion:
	Author of the package can be contacted via email: vmm@iki.fi
	Also visit http://south.rotol.ramk.fi/
*)

BeginPackage["vmmPolyTests`"]

Unprotect["vmmPolyTests`*"]

vmmMakeA2FreeInfix::usage="vmmMakeA2FreeInfix[prefix, infix, suffix] creates all a-2-free words of form prefix<>infix<>suffix. If such words don't exist, an empty list will be returned. Infix consists of variables ie. characters different from a, b, c and d. One variable can be used in different positions of infix. vmmMakeA2FreeInfix[prefix, infix, suffix, charList] works the same way, but values for variables can be limited with charList. "<>"\!\(\*ButtonBox[\"More\", ButtonData:>vmmMakeA2FreeInfix, Active->True, ButtonStyle->\"AddOnsLink\"]\)"

vmmMakeA2FreeWord::usage="vmmMakeA2FreeWord[word] creates all a-2-free words on four letters {a, b, c, d} that match the form of parameter word. Word consists of characters a, b, c and/or d and variables. vmmMakeA2FreeWord[word, charList] is form to use if the values of variables needs to be limited. "<>"\!\(\*ButtonBox[\"More\", ButtonData:>vmmMakeA2FreeWord, Active->True, ButtonStyle->\"AddOnsLink\"]\)"

vmmMakeA2FreeWords::usage="vmmMakeA2FreeWords[wordList] is basically the same function as vmmMakeA2FreeWord[word] on four letters {a, b, c, d} but instead of one word you can give many words as parameters and share variables between them. vmmMakeA2FreeWords[wordList, charList] is form to use if the values of variables needs to be limited"

vmmMakeA2FreeWords3let::usage="vmmMakeA2FreeWords3let is otherwise equal to vmmMakeA2FreeWords[wordList] but instead of using four letter alphabet {a, b, c, d} it uses three letter alphabet {a, b, c} and allows xx and xxx for a letter x."

vmmMakeA2FreeWords5let::usage="vmmMakeA2FreeWords5let is equal to vmmMakeA2FreeWords[wordList] but instead of using four letter alphabet {a, b, c, d} it uses five letter alphabet {a, b, c, d, e}."

vmmMakeA2FreeInfix5let::usage="vmmMakeA2FreeInfix5let[prefix, infix, suffix] creates all a-2-free words of form prefix<>infix<>suffix. If such words don't exist, an empty list will be returned. Infix consists of variables ie. characters different from a, b, c, d and e. One variable can be used in different positions of infix. vmmMakeA2FreeInfix5let[prefix, infix, suffix, charList] works the same way, but values for variables can be limited with charList. "<>"\!\(\*ButtonBox[\"More\", ButtonData:>vmmMakeA2FreeInfix5let, Active->True, ButtonStyle->\"AddOnsLink\"]\)"

vmmMakeA2FreeWord5let::usage="vmmMakeA2FreeWord5let[word] creates all a-2-free words that match the form of parameter word. Word consists of characters a, b, c, d and/or e and variables. vmmMakeA2FreeWord5let[word, charList] is form to use if the values of variables needs to be limited. "<>"\!\(\*ButtonBox[\"More\", ButtonData:>vmmMakeA2FreeWord5let, Active->True, ButtonStyle->\"AddOnsLink\"]\)"

vmmMakeA2FreeInfix3let::usage="vmmMakeA2FreeInfix3let[prefix, infix, suffix] creates all a-2-free words, allowing xx and xxx for a letter x, of form prefix<>infix<>suffix. If such words don't exist, an empty list will be returned. Infix consists of variables ie. characters different from a, b, c. One variable can be used in different positions of infix. vmmMakeA2FreeInfix3let[prefix, infix, suffix, charList] works the same way, but values for variables can be limited with charList. "<>"\!\(\*ButtonBox[\"More\", ButtonData:>vmmMakeA2FreeInfix3let, Active->True, ButtonStyle->\"AddOnsLink\"]\)"

vmmMakeA2FreeWord3let::usage="vmmMakeA2FreeWord3let[word] creates all a-2-free words, allowing xx and xxx for a letter x, that match the form of parameter word. Word consists of characters a, b, c and variables. vmmMakeA2FreeWord3let[word, charList] is form to use if the values of variables needs to be limited. "<>"\!\(\*ButtonBox[\"More\", ButtonData:>vmmMakeA2FreeWord3let, Active->True, ButtonStyle->\"AddOnsLink\"]\)"

vmmMakeA2FreeSuffix3let::usage="vmmMakeA2FreeSuffix3let is otherwise equal to vmmMakeA2FreeWord3let[word] but instead of studying the whole word, it studies only the suffix of the word and thus makes the computation faster and less memory consuming. The function uses three letter alphabet {a, b, c} and allows xx and xxx for a letter x."

vmmMakeA2FreeSuffixes3let::usage="vmmMakeA2FreeSuffixes3let is otherwise equal to vmmMakeA2FreeWords3let[wordList] but instead of studying all the whole words, it studies only the suffixes of the words (in a parallel way) and thus makes the computation faster and less memory consuming. The function uses three letter alphabet {a, b, c} and allows xx and xxx for a letter x."

vmmCreatePolynomsSuffix3let::usage="vmmMakeA2FreeSuffixes3let[word] creates the product polynomial for just the suffix of the word and thus makes the computation faster and less memory consuming. The function uses three letter alphabet {a, b, c} and allows xx and xxx for a letter x."

Begin["`Private`"]

Clear[vmmMakeA2FreeWord, vmmMakeA2FreeWords, vmmMakeA2FreeWord3let, vmmMakeA2FreeWord5let,vmmMakeA2FreeWords3let,vmmMakeA2FreeWords5let,vmmMakeA2FreeSuffix3let,vmmMakeA2FreeSuffixes3let];

vmmMakeA2FreeWord[str_String]:=
	Module[{myP, myV, myRes},
	
		myP=vmmCreatePolynoms[str];
		myV=vmmPickVariables[str];
		myRes=vmmTestPolynom[myP,myV,1];
		StringReplace[str, #]&/@myRes

	];

vmmMakeA2FreeWords[strs_List]:=
	Module[{myP, myV, myRes, mixUp},
	
		myP=vmmCreatePolynoms[#]&/@strs;
		(*Print[myP];*)
		myV=Flatten[Characters[vmmPickVariables[#]&/@strs]];
		(*Print[myV];*)
		myV=StringJoin[DeleteDuplicates[myV]];
		(*Print[myV];*)
		mixUp=Apply[Times, myP];
		(*Print[mixUp];*)
		myRes=vmmTestPolynom[mixUp, myV, 1];
		(*Print[myRes];*)
		StringReplace[strs, #]&/@myRes

	];

vmmMakeA2FreeWords[strs_List, charList_List]:=
	Module[{myP, myV, myRes, mixUp},
	
		myP=vmmCreatePolynoms[#]&/@strs;
		(*Print[myP];*)
		myV=Flatten[Characters[vmmPickVariables[#]&/@strs]];
		(*Print[myV];*)
		myV=StringJoin[DeleteDuplicates[myV]];
		(*Print[myV];*)
		mixUp=Apply[Times, myP];
		(*Print[mixUp];*)
		myRes=vmmTestPolynom[mixUp, myV, 1, charList];
		(*Print[myRes];*)
		StringReplace[strs, #]&/@myRes

	];

vmmMakeA2FreeWords3let[{},___]:={};

vmmMakeA2FreeSuffixes3let[strs_List]:=
	Module[{myP, myV, myRes, mixUp},
		myP=vmmCreatePolynomsSuffix3let[#]&/@strs;
		(*Print[myP];*)
		myV=Flatten[Characters[vmmPickVariables3let[#]&/@strs]];
		(*Print[myV];*)
		myV=StringJoin[DeleteDuplicates[myV]];
		(*Print[myV];*)
		mixUp=Apply[Times, myP];
		(*Print[mixUp];*)
		myRes=vmmTestPolynom3let[mixUp, myV, 1];
		(*Print[myRes];*)
		StringReplace[strs, #]&/@myRes];

vmmMakeA2FreeWords3let[strs_List]:=
	Module[{myP, myV, myRes, mixUp},
	
		myP=vmmCreatePolynoms3let[#]&/@strs;
		(*Print[myP];*)
		myV=Flatten[Characters[vmmPickVariables3let[#]&/@strs]];
		(*Print[myV];*)
		myV=StringJoin[DeleteDuplicates[myV]];
		(*Print[myV];*)
		mixUp=Apply[Times, myP];
		(*Print[mixUp];*)
		myRes=vmmTestPolynom3let[mixUp, myV, 1];
		(*Print[myRes];*)
		StringReplace[strs, #]&/@myRes

	];

vmmMakeA2FreeWords3let[strs_List, charList_List]:=
	Module[{myP, myV, myRes, mixUp},
	
		myP=vmmCreatePolynoms3let[#]&/@strs;
		(*Print[myP];*)
		myV=Flatten[Characters[vmmPickVariables3let[#]&/@strs]];
		(*Print[myV];*)
		myV=StringJoin[DeleteDuplicates[myV]];
		(*Print[myV];*)
		mixUp=Apply[Times, myP];
		(*Print[mixUp];*)
		myRes=vmmTestPolynom3let[mixUp, myV, 1, charList];
		(*Print[myRes];*)
		StringReplace[strs, #]&/@myRes

	];

vmmMakeA2FreeWords5let[strs_List]:=
	Module[{myP, myV, myRes, mixUp},
	
		myP=vmmCreatePolynoms[#]&/@strs;
		(*Print[myP];*)
		myV=Flatten[Characters[vmmPickVariables5let[#]&/@strs]];
		(*Print[myV];*)
		myV=StringJoin[DeleteDuplicates[myV]];
		(*Print[myV];*)
		mixUp=Apply[Times, myP];
		(*Print[mixUp];*)
		myRes=vmmTestPolynom5let[mixUp, myV, 1];
		(*Print[myRes];*)
		StringReplace[strs, #]&/@myRes

	];

vmmMakeA2FreeWords5let[strs_List, charList_List]:=
	Module[{myP, myV, myRes, mixUp},
	
		myP=vmmCreatePolynoms[#]&/@strs;
		(*Print[myP];*)
		myV=Flatten[Characters[vmmPickVariables5let[#]&/@strs]];
		(*Print[myV];*)
		myV=StringJoin[DeleteDuplicates[myV]];
		(*Print[myV];*)
		mixUp=Apply[Times, myP];
		(*Print[mixUp];*)
		myRes=vmmTestPolynom5let[mixUp, myV, 1, charList];
		(*Print[myRes];*)
		StringReplace[strs, #]&/@myRes

	];

vmmMakeA2FreeWord5let[str_String]:=
	Module[{myP, myV, myRes},
	
		myP=vmmCreatePolynoms[str];
		myV=vmmPickVariables5let[str];
		myRes=vmmTestPolynom5let[myP,myV,1];
		StringReplace[str, #]&/@myRes

	];

vmmMakeA2FreeSuffix3let[str_String]:=
	Module[{myP, myV, myRes},
		myP=vmmCreatePolynomsSuffix3let[str];
		myV=vmmPickVariables3let[str];
		myRes=vmmTestPolynom3let[myP,myV,1];
		StringReplace[str, #]&/@myRes];

vmmMakeA2FreeWord3let[str_String]:=
	Module[{myP, myV, myRes},
	
		myP=vmmCreatePolynoms3let[str];
		myV=vmmPickVariables3let[str];
		myRes=vmmTestPolynom3let[myP,myV,1];
		StringReplace[str, #]&/@myRes

	];

vmmMakeA2FreeWord[str_String, charList_List]:=
	Module[{myP, myV, myRes},

		myP=vmmCreatePolynoms[str];
		myV=vmmPickVariables[str];
		myRes=vmmTestPolynom[myP,myV,1,charList];
		StringReplace[str, #]&/@myRes

	];

vmmMakeA2FreeWord5let[str_String, charList_List]:=
	Module[{myP, myV, myRes},

		myP=vmmCreatePolynoms[str];
		myV=vmmPickVariables5let[str];
		myRes=vmmTestPolynom5let[myP,myV,1,charList];
		StringReplace[str, #]&/@myRes

	];

vmmMakeA2FreeWord3let[str_String, charList_List]:=
	Module[{myP, myV, myRes},

		myP=vmmCreatePolynoms3let[str];
		myV=vmmPickVariables3let[str];
		myRes=vmmTestPolynom3let[myP,myV,1,charList];
		StringReplace[str, #]&/@myRes

	];

Clear[vmmMakeA2FreeInfix, vmmMakeA2FreeInfix3let, vmmMakeA2FreeInfix5let];

vmmMakeA2FreeInfix[pref_String, inf_String, suff_String]:=
	Module[{myP,myV,myRes},

		myP=vmmGiveMeAPolynom[pref,inf,suff];
		myV=StringJoin[Union[Characters[inf]]];
		myRes=vmmTestPolynom[myP,myV,1];
		StringReplace[pref<>inf<>suff,#]&/@myRes
	];

vmmMakeA2FreeInfix5let[pref_String, inf_String, suff_String]:=
	Module[{myP,myV,myRes},

		myP=vmmGiveMeAPolynom[pref,inf,suff];
		myV=StringJoin[Union[Characters[inf]]];
		myRes=vmmTestPolynom5let[myP,myV,1];
		StringReplace[pref<>inf<>suff,#]&/@myRes
	];

vmmMakeA2FreeInfix3let[pref_String, inf_String, suff_String]:=
	Module[{myP,myV,myRes},

		myP=vmmGiveMeAPolynom3let[pref,inf,suff];
		myV=StringJoin[Union[Characters[inf]]];
		myRes=vmmTestPolynom3let[myP,myV,1];
		StringReplace[pref<>inf<>suff,#]&/@myRes
	];

vmmMakeA2FreeInfix[pref_String, inf_String, suff_String, charList_List]:=
	Module[{myP,myV,myRes},

		myP=vmmGiveMeAPolynom[pref,inf,suff];
		myV=StringJoin[Union[Characters[inf]]];
		myRes=vmmTestPolynom[myP,myV,1,charList];
		StringReplace[pref<>inf<>suff,#]&/@myRes
	];

vmmMakeA2FreeInfix5let[pref_String, inf_String, suff_String, charList_List]:=
	Module[{myP,myV,myRes},

		myP=vmmGiveMeAPolynom[pref,inf,suff];
		myV=StringJoin[Union[Characters[inf]]];
		myRes=vmmTestPolynom5let[myP,myV,1,charList];
		StringReplace[pref<>inf<>suff,#]&/@myRes
	];

vmmMakeA2FreeInfix3let[pref_String, inf_String, suff_String, charList_List]:=
	Module[{myP,myV,myRes},

		myP=vmmGiveMeAPolynom3let[pref,inf,suff];
		myV=StringJoin[Union[Characters[inf]]];
		myRes=vmmTestPolynom3let[myP,myV,1,charList];
		StringReplace[pref<>inf<>suff,#]&/@myRes
	];

vmmMakeA2FreeInfix[pref_String, infLen_Integer, suff_String]:=
	Module[{myP,myV,myRes},
		myV=vmmCreateVariables[infLen, 256];
		myP=vmmGiveMeAPolynom[pref,myV,suff];
		myRes=vmmTestPolynom[myP,myV,1];
		StringReplace[pref<>myV<>suff,#]&/@myRes
	];

vmmMakeA2FreeInfix5let[pref_String, infLen_Integer, suff_String]:=
	Module[{myP,myV,myRes},
		myV=vmmCreateVariables[infLen, 256];
		myP=vmmGiveMeAPolynom[pref,myV,suff];
		myRes=vmmTestPolynom5let[myP,myV,1];
		StringReplace[pref<>myV<>suff,#]&/@myRes
	];

vmmMakeA2FreeInfix3let[pref_String, infLen_Integer, suff_String]:=
	Module[{myP,myV,myRes},
		myV=vmmCreateVariables[infLen, 256];
		myP=vmmGiveMeAPolynom3let[pref,myV,suff];
		myRes=vmmTestPolynom3let[myP,myV,1];
		StringReplace[pref<>myV<>suff,#]&/@myRes
	];

Clear[vmmGiveMeAPolynom, vmmGiveMeAPolynom3let];

vmmGiveMeAPolynom[pref_String,inf_String,suff_String]:=
	Module[{str},
		str=pref<>inf<>suff;
		vmmCreatePolynoms[str, StringLength[pref]+1, StringLength[inf]+StringLength[pref]]
	];

vmmGiveMeAPolynom3let[pref_String,inf_String,suff_String]:=
	Module[{str},
		str=pref<>inf<>suff;
		vmmCreatePolynoms3let[str, StringLength[pref]+1, StringLength[inf]+StringLength[pref]]
	];

Clear[vmmCreatePolynoms, vmmCreatePolynoms3let,vmmCreatePolynomsSuffix3let];

vmmCreatePolynoms[str_String, startOfInfix_Integer:2]:=
	Module[{u,v,pu,pv,b,m,e,res={}},

		e=startOfInfix;
		While[e<=StringLength[str],
			m=e;
			b=m-1;
			While[b>0,
				v=StringTake[str,{m,e}];
				u=StringTake[str,{b,m-1}];
				pv=vmmParikh[v];
				pu=vmmParikh[u];
				AppendTo[res,(pv-pu)];
				m=m-1;
				b=b-2;
			];
			e=e+1;
		];
		Times@@res

	];

vmmCreatePolynomsSuffix3let[str_String]:=
	Module[{pu,pv,b,m,e,res={}},
		e=StringLength[str];
			m=e-1;b=m-2;
			While[b>0,
				pv=vmmParikh[StringTake[str,{m,e}]];
			pu=vmmParikh[StringTake[str,{b,m-1}]];
				(* Print[{pu,pv}]; *)
			AppendTo[res,(pv-pu)];
				m=m-1; b=b-2;];
		Times@@res];

(* Above requires that StringLength[str] \[GreaterEqual] 4 *)

vmmCreatePolynoms3let[str_String, startOfInfix_Integer:4]:=
	Module[{u,v,pu,pv,b,m,e,res={}},

		e=startOfInfix;
		While[e<=StringLength[str],
			m=e-1;
			b=m-2;
			While[b>0,
				v=StringTake[str,{m,e}];
				u=StringTake[str,{b,m-1}];
				pv=vmmParikh[v];
				pu=vmmParikh[u];
				AppendTo[res,(pv-pu)];
				m=m-1;
				b=b-2;
			];
			e=e+1;
		];
		Times@@res

	];

vmmCreatePolynoms[str_String, startOfInfix_Integer, endOfInfix_Integer]:=
	Module[{u,v,pu,pv,b,m,e,res={}},

		e=startOfInfix;
		While[e<=StringLength[str],
			If[e>endOfInfix+1,
				(If[OddQ[endOfInfix]==OddQ[e],
					(b=endOfInfix-1; m=Ceiling[(e-b)/2]+b;),
					(b=endOfInfix; m=Ceiling[(e-b)/2]+b;)
				];),
				(m=e; b=m-1;)
			];
			While[b>0,
				v=StringTake[str,{m,e}];
				u=StringTake[str,{b,m-1}];
				pv=vmmParikh[v];
				pu=vmmParikh[u];
				AppendTo[res,(pv-pu)];
				m=m-1;
				b=b-2;
			];
			e=e+1;
		];
		Times@@res

	];

vmmCreatePolynoms3let[str_String, startOfInfix_Integer, endOfInfix_Integer]:=
	Module[{u,v,pu,pv,b,m,e,res={}},

		e=startOfInfix;
		While[e<=StringLength[str],
			If[e>endOfInfix+1,
				(If[OddQ[endOfInfix]==OddQ[e],
					(b=endOfInfix-1; m=Ceiling[(e-b)/2]+b;),
					(b=endOfInfix; m=Ceiling[(e-b)/2]+b;)
				];),
				(m=e-1; b=m-2;)
			];
			While[b>0,
				v=StringTake[str,{m,e}];
				u=StringTake[str,{b,m-1}];
				pv=vmmParikh[v];
				pu=vmmParikh[u];
				AppendTo[res,(pv-pu)];
				m=m-1;
				b=b-2;
			];
			e=e+1;
		];
		Times@@res

	];

Clear[vmmParikh];

vmmParikh[x_List]:=Apply[Plus,x];
vmmParikh[x_String]:=Apply[Plus, Characters[x]];

Clear[vmmTestPolynom, vmmTestPolynom3let, vmmTestPolynom5let];

vmmTestPolynom[polynGroup_, vars_String, outputType_Integer:1]:=
	Module[{polyList,res,pr,silmu=3},

		polyList=DeleteCases[({StringTake[vars, {1,1}]->#,polynGroup/.StringTake[vars, {1,1}]->#})&/@Characters["abcd"],{_,0}];

		If[StringLength[vars]==1,
			Return[Take[#,1]&/@polyList]
		];

		res=DeleteCases[{{#[[1]]},vmmSolvePolynom[#[[2]],StringTake[vars,{2,2}]]}&/@polyList,{_,{}}];

		pr=Outer[List,#[[1]],#[[2]]]&/@res//Flatten[#,2]&;

		While[silmu<=StringLength[vars],
			polyList={#,polynGroup/.#}&/@pr;
			res=DeleteCases[{{#[[1]]},vmmSolvePolynom[#[[2]],StringTake[vars, {silmu,silmu}]]}&/@polyList,{_,{}}];
			pr=Outer[List,#[[1]],#[[2]],1,1]&/@res//Flatten[#,2]&;
			pr=Flatten/@pr;
			silmu=silmu+1;
		];

		If[outputType==2,
			Return[StringReplace[StringTake[vars, silmu-1],#]&/@pr],
			Return[pr]
		]
	];

vmmTestPolynom5let[polynGroup_, vars_String, outputType_Integer:1]:=
	Module[{polyList,res,pr,silmu=3},

		polyList=DeleteCases[({StringTake[vars, {1,1}]->#,polynGroup/.StringTake[vars, {1,1}]->#})&/@Characters["abcde"],{_,0}];

		If[StringLength[vars]==1,
			Return[Take[#,1]&/@polyList]
		];

		res=DeleteCases[{{#[[1]]},vmmSolvePolynom5let[#[[2]],StringTake[vars,{2,2}]]}&/@polyList,{_,{}}];

		pr=Outer[List,#[[1]],#[[2]]]&/@res//Flatten[#,2]&;

		While[silmu<=StringLength[vars],
			polyList={#,polynGroup/.#}&/@pr;
			res=DeleteCases[{{#[[1]]},vmmSolvePolynom5let[#[[2]],StringTake[vars, {silmu,silmu}]]}&/@polyList,{_,{}}];
			pr=Outer[List,#[[1]],#[[2]],1,1]&/@res//Flatten[#,2]&;
			pr=Flatten/@pr;
			silmu=silmu+1;
		];

		If[outputType==2,
			Return[StringReplace[StringTake[vars, silmu-1],#]&/@pr],
			Return[pr]
		]
	];

vmmTestPolynom3let[polynGroup_, vars_String, outputType_Integer:1]:=
	Module[{polyList,res,pr,silmu=3},

		polyList=DeleteCases[({StringTake[vars, {1,1}]->#,polynGroup/.StringTake[vars, {1,1}]->#})&/@Characters["abc"],{_,0}];

		If[StringLength[vars]==1,
			Return[Take[#,1]&/@polyList]
		];

		res=DeleteCases[{{#[[1]]},vmmSolvePolynom3let[#[[2]],StringTake[vars,{2,2}]]}&/@polyList,{_,{}}];

		pr=Outer[List,#[[1]],#[[2]]]&/@res//Flatten[#,2]&;

		While[silmu<=StringLength[vars],
			polyList={#,polynGroup/.#}&/@pr;
			res=DeleteCases[{{#[[1]]},vmmSolvePolynom3let[#[[2]],StringTake[vars, {silmu,silmu}]]}&/@polyList,{_,{}}];
			pr=Outer[List,#[[1]],#[[2]],1,1]&/@res//Flatten[#,2]&;
			pr=Flatten/@pr;
			silmu=silmu+1;
		];

		If[outputType==2,
			Return[StringReplace[StringTake[vars, silmu-1],#]&/@pr],
			Return[pr]
		]
	];

vmmTestPolynom[polynGroup_, vars_String, outputType_Integer:1, charList_List]:=
	Module[{polyList,res,pr,silmu=3},

		polyList=DeleteCases[({StringTake[vars, {1,1}]->#,polynGroup/.StringTake[vars, {1,1}]->#})&/@vmmFindTestChars[StringTake[vars,{1,1}],charList],{_,0}];

		If[StringLength[vars]==1,
			Return[Take[#,1]&/@polyList]
		];

		res=DeleteCases[{{#[[1]]},vmmSolvePolynom[#[[2]],StringTake[vars,{2,2}],vmmFindTestChars[StringTake[vars, {2,2}],charList]]}&/@polyList,{_,{}}];

		pr=Outer[List,#[[1]],#[[2]]]&/@res//Flatten[#,2]&;

		While[silmu<=StringLength[vars],
			polyList={#,polynGroup/.#}&/@pr;
			res=DeleteCases[{{#[[1]]},vmmSolvePolynom[#[[2]],StringTake[vars, {silmu,silmu}],vmmFindTestChars[StringTake[vars,{silmu,silmu}],charList]]}&/@polyList,{_,{}}];
			pr=Outer[List,#[[1]],#[[2]],1,1]&/@res//Flatten[#,2]&;
			pr=Flatten/@pr;
			silmu=silmu+1;
		];

		If[outputType==2,
			Return[StringReplace[StringTake[vars, silmu-1],#]&/@pr],
			Return[pr]
		]
	];

vmmTestPolynom5let[polynGroup_, vars_String, outputType_Integer:1, charList_List]:=
	Module[{polyList,res,pr,silmu=3},

		polyList=DeleteCases[({StringTake[vars, {1,1}]->#,polynGroup/.StringTake[vars, {1,1}]->#})&/@vmmFindTestChars5let[StringTake[vars,{1,1}],charList],{_,0}];

		If[StringLength[vars]==1,
			Return[Take[#,1]&/@polyList]
		];

		res=DeleteCases[{{#[[1]]},vmmSolvePolynom5let[#[[2]],StringTake[vars,{2,2}],vmmFindTestChars5let[StringTake[vars, {2,2}],charList]]}&/@polyList,{_,{}}];

		pr=Outer[List,#[[1]],#[[2]]]&/@res//Flatten[#,2]&;

		While[silmu<=StringLength[vars],
			polyList={#,polynGroup/.#}&/@pr;
			res=DeleteCases[{{#[[1]]},vmmSolvePolynom5let[#[[2]],StringTake[vars, {silmu,silmu}],vmmFindTestChars5let[StringTake[vars,{silmu,silmu}],charList]]}&/@polyList,{_,{}}];
			pr=Outer[List,#[[1]],#[[2]],1,1]&/@res//Flatten[#,2]&;
			pr=Flatten/@pr;
			silmu=silmu+1;
		];

		If[outputType==2,
			Return[StringReplace[StringTake[vars, silmu-1],#]&/@pr],
			Return[pr]
		]
	];

vmmTestPolynom3let[polynGroup_, vars_String, outputType_Integer:1, charList_List]:=
	Module[{polyList,res,pr,silmu=3},

		polyList=DeleteCases[({StringTake[vars, {1,1}]->#,polynGroup/.StringTake[vars, {1,1}]->#})&/@vmmFindTestChars3let[StringTake[vars,{1,1}],charList],{_,0}];

		If[StringLength[vars]==1,
			Return[Take[#,1]&/@polyList]
		];

		res=DeleteCases[{{#[[1]]},vmmSolvePolynom3let[#[[2]],StringTake[vars,{2,2}],vmmFindTestChars3let[StringTake[vars, {2,2}],charList]]}&/@polyList,{_,{}}];

		pr=Outer[List,#[[1]],#[[2]]]&/@res//Flatten[#,2]&;

		While[silmu<=StringLength[vars],
			polyList={#,polynGroup/.#}&/@pr;
			res=DeleteCases[{{#[[1]]},vmmSolvePolynom3let[#[[2]],StringTake[vars, {silmu,silmu}],vmmFindTestChars3let[StringTake[vars,{silmu,silmu}],charList]]}&/@polyList,{_,{}}];
			pr=Outer[List,#[[1]],#[[2]],1,1]&/@res//Flatten[#,2]&;
			pr=Flatten/@pr;
			silmu=silmu+1;
		];

		If[outputType==2,
			Return[StringReplace[StringTake[vars, silmu-1],#]&/@pr],
			Return[pr]
		]
	];

Clear[vmmSolvePolynom, vmmSolvePolynom3let, vmmSolvePolynom5let];

vmmSolvePolynom[pol_, var_, charList_:{"a","b","c","d"}]:=
	(If[(pol/.ToString[var]->#)=!=0,
		ToString[var]->#,
		{}
	]&/@charList//Flatten);

vmmSolvePolynom5let[pol_, var_, charList_:{"a","b","c","d","e"}]:=
	(If[(pol/.ToString[var]->#)=!=0,
		ToString[var]->#,
		{}
	]&/@charList//Flatten);

vmmSolvePolynom3let[pol_, var_, charList_:{"a","b","c"}]:=
	(If[(pol/.ToString[var]->#)=!=0,
		ToString[var]->#,
		{}
	]&/@charList//Flatten);

Clear[vmmPickVariables, vmmPickVariables3let, vmmPickVariables5let];

vmmPickVariables[str_String]:=
	Module[{},
		StringJoin[Complement[Union[Characters[str]], Characters["abcd"]]]
	];

vmmPickVariables5let[str_String]:=
	Module[{},
		StringJoin[Complement[Union[Characters[str]], Characters["abcde"]]]
	];

vmmPickVariables3let[str_String]:=
	Module[{},
		StringJoin[Complement[Union[Characters[str]], Characters["abc"]]]
	];

Clear[vmmFindTestChars, vmmFindTestChars3let, vmmFindTestChars5let];

vmmFindTestChars[var_,charList_]:=
	Module[{pos,subList,res},

		pos=Flatten[Position[charList,var]];

		If[pos=={},
			res=Characters["abcd"];,
			(
			subList=Flatten[Take[charList,{pos[[1]],pos[[1]]}]];
			res=Extract[subList,#]&/@Flatten[Position[subList,#]&/@Characters["abcd"]];
			res=Flatten[Characters[res]];
			)
		];
		Return[res]
	];

vmmFindTestChars5let[var_,charList_]:=
	Module[{pos,subList,res},

		pos=Flatten[Position[charList,var]];

		If[pos=={},
			res=Characters["abcde"];,
			(
			subList=Flatten[Take[charList,{pos[[1]],pos[[1]]}]];
			res=Extract[subList,#]&/@Flatten[Position[subList,#]&/@Characters["abcde"]];
			res=Flatten[Characters[res]];
			)
		];
		Return[res]
	];

vmmFindTestChars3let[var_,charList_]:=
	Module[{pos,subList,res},

		pos=Flatten[Position[charList,var]];

		If[pos=={},
			res=Characters["abc"];,
			(
			subList=Flatten[Take[charList,{pos[[1]],pos[[1]]}]];
			res=Extract[subList,#]&/@Flatten[Position[subList,#]&/@Characters["abc"]];
			res=Flatten[Characters[res]];
			)
		];
		Return[res]
	];

Clear[vmmCreateVariables];

vmmCreateVariables[variableCount_Integer, startingCode_Integer:65]:=
	Module[{},
		FromCharacterCode[Range[#,(#+variableCount-1)]&[startingCode]]
	];

End[]

Protect["vmmPolyTests`*"]

EndPackage[]



