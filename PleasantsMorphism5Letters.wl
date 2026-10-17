(* ::Package:: *)

(* ::Title:: *)
(*Pleasants' 5-letter endomorphism (1969/1970): a2f tests*)


(* ::Text:: *)
(*P. A. B. Pleasants, Non-repetitive sequences, Proc. Cambridge Philos. Soc. 68 (1970) 267-274.*)
(*Images as in "5_Letters_Pleasants_1969.pdf": g(a) = bacaeacadaeadab, and g(b), ..., g(e) are obtained by the*)
(*cyclic permutation a->b->c->d->e->a. Size 5 x 15 = 75, Parikh vector of g(x) is 7 for x and 2 for the others.*)
(**)
(*Contents*)
(*  plG, plImage, plIterate                 - the endomorphism and its iterates*)
(*  plFirstAbelianSquare, plA2FQ           - abelian-square test (vectorised over prefix Parikh vectors)*)
(*  plA2FWordsLevels                        - all a2f words starting with "a", level by level*)
(*  plTestPreservation                      - is g(w) a2f for every a2f w with |w| <= n ?*)
(*  plRandomA2FWord, plRandomTest           - random long a2f words w, test g(w)*)
(**)
(*Letters are coded a,b,c,d,e -> 1..5 internally. Because the cyclic shift commutes with g,*)
(*it suffices to test words w starting with "a".*)


(* ::Section:: *)
(*The endomorphism*)


plAlphabet = CharacterRange["a", "e"];

plShift[w_String] := StringReplace[w, Thread[plAlphabet -> RotateLeft[plAlphabet]]];

plGa = "bacaeacadaeadab";

plG = AssociationThread[plAlphabet, NestList[plShift, plGa, 4]];

plImage[w_String] := StringJoin[plG /@ Characters[w]];

(* g^k(w) *)
plIterate[w_String, k_Integer] := Nest[plImage, w, k];

(* integer images: plGInt[[x]] = codes of g(letter x) *)
plGInt = (ToCharacterCode[#] - 96) & /@ Values[plG];

plCodes[w_String] := ToCharacterCode[w] - 96;
plString[c_List] := FromCharacterCode[c + 96];


(* ::Section:: *)
(*Abelian squares*)


(* Prefix Parikh vectors: row i+1 = letter counts of the first i letters. *)
plPrefixParikh[c_List] := Prepend[Accumulate[IdentityMatrix[5][[c]]], ConstantArray[0, 5]];

(* First abelian square uv in w as {start position (1-based), |u|}, or Missing["NotFound"]. *)
plFirstAbelianSquare[w_String] := plFirstAbelianSquare[plCodes[w]];
plFirstAbelianSquare[c_List] := Module[{n = Length[c], P, d, hit},
  P = plPrefixParikh[c];
  Catch[
   Do[
    d = Drop[P, l] - Drop[P, -l];   (* d[[i]] = Parikh vector of w[i .. i+l-1] *)
    hit = Position[Total[Abs[Drop[d, -l] - Drop[d, l]], {2}], 0, {1}, 1];
    If[hit =!= {}, Throw[{hit[[1, 1]], l}]],
    {l, 1, Quotient[n, 2]}];
   Missing["NotFound"]]]

plA2FQ[w_] := MissingQ[plFirstAbelianSquare[w]];

(* Show an abelian square found in w as "u|v" *)
plShowSquare[w_String, {p_Integer, l_Integer}] :=
  StringTake[w, {p, p + l - 1}] <> "|" <> StringTake[w, {p + l, p + 2 l - 1}];


(* ::Section:: *)
(*Level-wise enumeration of a2f words and the preservation test*)


(* Prefix Parikh tensor for a matrix of words (rows): dims {N, len+1, 5} *)
plPrefixParikhRows[W_List] := Module[{oh = IdentityMatrix[5][[#]] & /@ W},
  Join[ConstantArray[0, {Length[W], 1, 5}], Accumulate /@ oh, 2]];

(* Extend each a2f word (row of W) by one letter, keeping only a2f results.
   Only abelian squares that are suffixes need to be checked. *)
plExtendA2F[W_List] := Module[{n = Length[First[W]] + 1, cand, P, bad},
  cand = Flatten[Table[Append[w, x], {w, W}, {x, 5}], 1];
  cand = Select[cand, #[[-1]] != #[[-2]] &];
  P = plPrefixParikhRows[cand];
  bad = ConstantArray[0, Length[cand]];
  Do[
   bad += 1 - Unitize[Total[Abs[(P[[All, n + 1]] - P[[All, n - l + 1]]) - (P[[All, n - l + 1]] - P[[All, n - 2 l + 1]])], {2}]],
   {l, 1, Quotient[n, 2]}];
  Pick[cand, Unitize[bad], 0]]

(* All a2f words of length 1..n starting with "a" (as code lists), one list per length *)
plA2FWordsLevels[n_Integer] := NestList[plExtendA2F, {{1}}, n - 1];

(* For a matrix of a2f words W of length n (whose prefixes were already tested), return the
   indices i such that g(W[[i]]) has an abelian square ending inside the last image block,
   each with {start, half-length}. *)
plNewSquaresInImage[W_List] := Module[{n = Length[First[W]], m = Length[First[plGInt]], GW, P, len, res = {}, hits},
  GW = Flatten[plGInt[[#]]] & /@ W;
  P = plPrefixParikhRows[GW];
  len = n m;
  Do[
   hits = Flatten[Position[Total[Abs[(P[[All, e + 1]] - P[[All, e - l + 1]]) - (P[[All, e - l + 1]] - P[[All, e - 2 l + 1]])], {2}], 0]];
   If[hits =!= {}, res = Join[res, {#, {e - 2 l + 1, l}} & /@ hits]],
   {e, (n - 1) m + 1, len}, {l, 1, Quotient[e, 2]}];
  res]

(* Test: is g(w) a2f for all a2f words w (starting with "a") of length <= nMax?
   Prints one line per length and returns the first counterexample found, or None. *)
plTestPreservation[nMax_Integer] := Module[{W = {{1}}, bad, t, n},
  Catch[
   For[n = 1, n <= nMax, n++,
    If[n > 1, W = plExtendA2F[W]];
    {t, bad} = AbsoluteTiming[plNewSquaresInImage[W]];
    Print["len ", n, ": ", Length[W], " a2f words starting with a; g(w) non-a2f: ", Length[bad],
     "  (", Round[t, 0.1], " s)"];
    If[bad =!= {},
     With[{w = plString[W[[bad[[1, 1]]]]]},
      Throw[<|"w" -> w, "g(w)" -> plImage[w], "square" -> plShowSquare[plImage[w], bad[[1, 2]]]|>]]]];
   None]]


(* ::Section:: *)
(*Random long a2f words*)


(* random a2f word of length n by randomised backtracking (iterative: choices[[k]] holds the
   untried letters for position k) *)
plRandomA2FWord[n_Integer] := Module[{w = {}, choices = {RandomSample[Range[5]]}},
  While[Length[w] < n,
   If[choices[[-1]] === {},
    (* dead end: backtrack *)
    choices = Most[choices]; w = Most[w],
    AppendTo[w, First[choices[[-1]]]]; choices[[-1]] = Rest[choices[[-1]]];
    If[plSuffixA2FQ[w], AppendTo[choices, RandomSample[Range[5]]], w = Most[w]]]];
  plString[w]]

(* no abelian square as a suffix *)
plSuffixA2FQ[c_List] := Module[{n = Length[c], a = ConstantArray[0, 5], b = ConstantArray[0, 5]},
  Catch[
   Do[
    a[[c[[n - l + 1]]]]++; b[[c[[n - l + 1]]]]--; b[[c[[n - 2 l + 1]]]]++; b[[c[[n - 2 l + 2]]]]++;
    If[a == b, Throw[False]],
    {l, 1, Quotient[n, 2]}];
   True]]

(* test g on k random a2f words with lengths drawn from lens *)
plRandomTest[k_Integer, lens_List : {20, 30, 50, 80, 120, 200}] := Catch[
  Do[
   With[{w = plRandomA2FWord[RandomChoice[lens]]},
    With[{r = plFirstAbelianSquare[plImage[w]]},
     If[! MissingQ[r], Throw[<|"w" -> w, "square" -> plShowSquare[plImage[w], r]|>]]]],
   {k}];
  Print[k, " random a2f words tested, no counterexample"]; None]


(* ::Section:: *)
(*Example runs (evaluate in a notebook or with wolframscript -file)*)


(*
plG
plA2FQ[plIterate["a", 3]]                 (* 3375 letters; g^4 has 50625 letters, slower *)
Length /@ plA2FWordsLevels[7]             (* {1,4,16,60,228,828,3012} *)
plTestPreservation[9]
plRandomTest[200]
*)
