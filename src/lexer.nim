#[ 

 _______       .-''-.  ,---.   .--..-./`)                                                      
\  ____  \   .'_ _   \ |    \  |  |\ .-.')                                                     
| |    \ |  / ( ` )   '|  ,  \ |  |/ `-' \                                                     
| |____/ / . (_ o _)  ||  |\_ \|  | `-'`"`                                                     
|   _ _ '. |  (_,_)___||  _( )_\  | .---.                                                      
|  ( ' )  \'  \   .---.| (_ o _)  | |   |                                                      
| (_{;}_) | \  `-'    /|  (_,_)\  | |   |                                                      
|  (_,_)  /  \       / |  |    |  | |   |                                                      
/_______.'    `'-..-'  '--'    '--' '---'                                                      
    _______      ,-----.    ,---.    ,---..-------. .-./`)   .---.       .-''-.  .-------.     
   /   __  \   .'  .-,  '.  |    \  /    |\  _(`)_ \\ .-.')  | ,_|     .'_ _   \ |  _ _   \    
  | ,_/  \__) / ,-.|  \ _ \ |  ,  \/  ,  || (_ o._)|/ `-' \,-./  )    / ( ` )   '| ( ' )  |    
,-./  )      ;  \  '_ /  | :|  |\_   /|  ||  (_,_) / `-'`"`\  '_ '`) . (_ o _)  ||(_ o _) /    
\  '_ '`)    |  _`,/ \ _/  ||  _( )_/ |  ||   '-.-'  .---.  > (_)  ) |  (_,_)___|| (_,_).' __  
 > (_)  )  __: (  '\_/ \   ;| (_ o _) |  ||   |      |   | (  .  .-' '  \   .---.|  |\ \  |  | 
(  .  .-'_/  )\ `"/  \  ) / |  (_,_)  |  ||   |      |   |  `-'`-'|___\  `-'    /|  | \ `'   / 
 `-'`-'     /  '. \_/``".'  |  |      |  |/   )      |   |   |        \\       / |  |  \    /  
   `._____.'     '-----'    '--'      '--'`---'      '---'   `--------` `'-..-'  ''-'   `'-'   
    
]#

import std/strutils

type
  TokenType* = enum
    ## Define token type with corresponding appearence
    tkInvalid, tkId,
    # Keywords:
    # if keywords are changed, watch out to also adjust 'const keywords' range
    tkAls = "als", tkAuf = "auf",
    tkDefiniere = "definiere", tkDurch = "durch",
    tkEingabe = "eingabe",
    tkFalls = "falls",
    tkGib = "gib", tkGleich = "gleich", tkGroesser = "groesser",
    #tkIst = "ist",
    tkKleiner = "kleiner"
    tkMach = "mach", tkMal = "mal", tkMerke = "merke", tkMinus = "minus", tkModulo = "modulo",
    tkOk = "ok", tkOder = "oder",
    tkPlus = "plus",
    tkSchreibe = "schreibe", tkSetze = "setze", tkSonst = "sonst", tkSolange = "solange",
    tkUnd = "und",
    tkVon = "von",
    tkZu = "zu"
    # Datatypes
    tkTypNichts = "nichts", tkTypGanzzahl = "ganzzahl", tkTypText = "text", tkTypBool = "boolsch",
    tkGanzzahl, tkText, tkBool,
    # Symbols
    tkTerm = "term", tkParOp = "parOpen", tkParCl = "parClosed"#, tkDash = "dash"

  Token* = object
    ## Token with tokenType and optional value
    case tokenType*: TokenType
    of tkId: id*: string
    of tkGanzzahl: num*: int
    of tkText: str*: string
    of tkBool: bol*: bool
    else: discard
    line*, col*: int

const keywords* = {tkAls..tkTypBool}


proc `$`*(tokens: seq[Token]): string =
  ## Print sequence of token in one line each
  result = "Token[\n"
  for i, t in tokens:
    result &= "    $# $#,\n" % [$i, $t]
  result &= "]"

proc tokenize*(input: string): seq[Token] =
  ## Read a single input string and build a sequence of Tokens according to BENI
  for line_index, line in splitLines(input).pairs():  # Go through all input lines
    var index:  int = 0  ## Index of the current tokenized char
    let line_len: int = len(line)  ## Index of the current tokenized input line

    while index < line_len:
      var c = line[index]  # get current char
      let init_index = index  ## Start index of token
      inc index            # increment current char index

      case c  # check first char of new token
      of '#': break  # comment
      of '!': result.add(Token(tokenType: tkTerm, line: line_index, col: init_index))  # semicolon
      of '(': result.add(Token(tokenType: tkParOp, line: line_index, col: init_index)) # parenthesis open
      of ')': result.add(Token(tokenType: tkParCl, line: line_index, col: init_index)) # parenthesis closed
      of Whitespace: discard  # whitespace seperates tokens

      of '-', '0'..'9':  # recognize integer
        var value: string = $c
        while index < line_len and line[index] in '0'..'9':
          # Read more digits
          value &= line[index]
          inc index

        if value == "-":
          # Token is interpreted as a minus (eg. -x) if no digit follows
          # result.add(Token(tokenType: tkDash, line: line_index, col: init_index))
          # continue
          raise newException(ValueError, "digits expected")
        # Token is interpreted as a integer if at least on digit
        result.add(Token(tokenType: tkGanzzahl, num: parseInt(value), line: line_index, col: init_index))

      of '"':  # recognize literal string
        var value: string = ""

        while index < line_len and line[index] != '"':
          # add characters until closing " is encountered
          value &= line[index]
          inc index

        if index == line_len:
          # Fail if line ends before " is encountered
          raise newException(ValueError, "Unclosed string at $#:$#" % [$line_index, $init_index])
        
        inc index  # skip closing double quotes
        result.add(Token(tokenType: tkText, str: value, line: line_index, col: init_index))

      of IdentStartChars:  # recognize identifiers and keywords
        var value: string = $c
        while index < line_len and line[index] in IdentChars:
          # add characters until not identifier chars anymore
          value &= line[index]
          inc index

        # Check if identifier is actually a keyword
        var isKeyword: bool = false
        if value == "wahr":
          result.add(Token(tokenType: tkBool, bol: true))
          isKeyword = true
        elif value == "falsch":
          result.add(Token(tokenType: tkBool, bol: false))
          isKeyword = true
        for keyword in keywords:
          if $keyword == value: # check if keyword's string representation is equal
            result.add(Token(tokenType: keyword, line: line_index, col: init_index))
            isKeyword = true
            break
        if not isKeyword:
          result.add(Token(tokenType: tkId, id: value, line: line_index, col: init_index))
      
      else:
        # Fail on unknown symbol / token
        raise newException(ValueError, "Unknown symbol at $#:$# -> $# ($#)" % [$line_index, $init_index, $c, $ord(c)])
