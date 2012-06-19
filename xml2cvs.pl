
:- style_check(-atom).
:- use_module(library(dialect/hprolog)).

convert(InPlik,OutPlik):-
  open(InPlik, read, _, [alias(inp),buffer(line)]),
  open(OutPlik, write, _,[alias(outp),buffer(line)]),
  findall(P,stream_property(outp, P),Props),
  writeln(Props),
  repeat,
    (at_end_of_stream(inp),!
    ;
    read_line_to_codes(inp,String),
    sublist("<tags>",String), 
    zryj_tagi(inp,TagString), 
    flatten(TagString,TagStringF),
    wypisz_rekord(outp,TagStringF),
    false
    ),
  close(inp), close(outp).
 
szukaj_tagow(Inp,_):- at_end_of_stream(Inp),!.
szukaj_tagow(Inp,Outp):-
  read_line_to_codes(Inp,String),
  ( sublist("<tags>",String) -> zryj_tagi(Inp,TagString), flatten(TagString,TagStringF), wypisz_rekord(Outp,TagStringF) ; true ),
  szukaj_tagow(Inp,Outp).
  

zryj_tagi(Inp,TagString):-
  read_line_to_codes(Inp,String),
  ( sublist("</tags>",String) -> TagString = [] ; zryj_tagi(Inp,TagRest), TagString = [String|TagRest] ).
  
wypisz_rekord(Outp,Tags):-
  phrase(tagi(Rekord),Tags),atomic_list_concat(Rekord, ',', A),write(Outp,A),nl(Outp).
  
tagi([Id|Rekord]) --> white_space, "<tag>",!, white_space, "<name>",identifier(Id), close_tag, tagi(Rekord).
tagi([]) --> [].

white_space --> [C], { code_type(C, space) }, !, white_space.
white_space --> [].

nom([]) --> "<",!.
nom([C|IdR]) --> [C],nom(IdR). 

ident(L, Id) --> nom(IdR), { atom_codes(Id, [L|IdR]) }.

identifier(Id) --> [L],!, ident(L, Id).

close_tag --> "</tag>",!.
close_tag --> [_],close_tag.
