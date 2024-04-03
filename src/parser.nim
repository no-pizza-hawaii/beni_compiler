#[                                         
 _______  _______  __    _  ___                                       
|  _    ||       ||  |  | ||   |                                      
| |_|   ||    ___||   |_| ||   |                                      
|       ||   |___ |       ||   |                                      
|  _   | |    ___||  _    ||   |                                      
| |_|   ||   |___ | | |   ||   |                                      
|_______||_______||_|  |__||___|                                      
 _______  _______  __   __  _______  ___   ___      _______  ______   
|       ||       ||  |_|  ||       ||   | |   |    |       ||    _ |  
|       ||   _   ||       ||    _  ||   | |   |    |    ___||   | ||  
|       ||  | |  ||       ||   |_| ||   | |   |    |   |___ |   |_||_ 
|      _||  |_|  ||       ||    ___||   | |   |___ |    ___||    __  |
|     |_ |       || ||_|| ||   |    |   | |       ||   |___ |   |  | |
|_______||_______||_|   |_||___|    |___| |_______||_______||___|  |_|

]#

from lexer import Token, TokenType, keywords
import std/strutils
import std/sequtils
import std/tables

type
  DataType* = enum
    INT, TEXT, BOOL, VOID

  NodeType* = enum
    NONE, PROGRAM, FUNCTION
    IF_STATEMENT, IF_ELSE_STATEMENT, WHILE_STATEMENT, CONDITION,
    DECLARATION, ASSIGNMENT, RETURN, PRINT, INPUT,
    PARENTHESIS, OPERATION, IDENTIFIER, CALL,# DATA_TYPE,
    STRING_LITERAL, NUMBER_LITERAL, BOOL_LITERAL

  Node* = ref object
    info*:   Node  # id, numerial value, string value, condition, etc
    body*:   seq[Node]  # statements
    case nodeType*: NodeType
    of FUNCTION:
      args*:   Table[string, DataType]
      ret*:    DataType
    of IF_ELSE_STATEMENT:
      body_else*: seq[Node]
    of DECLARATION, INPUT:
      d_type*: DataType
    of IDENTIFIER, STRING_LITERAL, OPERATION:
      str*:     string
    of NUMBER_LITERAL:
      num*:    int
    of BOOL_LITERAL:
      bol*:    bool
    else: discard
    line*, col*: int

var
  symbols*: Table[string, DataType]
  funcs*: Table[string, Table[string, DataType]]


proc `$`*(node: Node): string = 
  if node == nil:
    return "nil"
  case node.nodeType
  of IDENTIFIER, STRING_LITERAL: return $node.nodeType & ": " & node.str
  of NUMBER_LITERAL: return $node.nodeType & ": " & $node.num
  of BOOL_LITERAL: return $node.nodeType & ": " & $node.bol
  else: discard

  var infoStr = ($node.info).splitLines().map(proc (l: string): string = "  " & l).join("\n")
  var bodyStr = ($node.body).splitLines().map(proc (l: string): string = "  " & l).join("\n")
  return "$#\ninfo:\n  $#\nbody:\n  $#" % [$node.nodeType, infoStr, bodyStr]

proc isType*(node: Node, ntype: NodeType): bool =
  return node.nodeType == ntype

proc parse*(tokens: seq[Token]): Node =
  result = Node(nodeType: PROGRAM)
  var index: int = 0

  proc walk(): Node =
    if index >= len(tokens):
      raise newException(ValueError, "Missing token")
    let token = tokens[index]
    echo "Walk at ", index, ": ", token

    inc index

    case token.tokenType
    of tkGanzzahl: result = Node(nodeType: NUMBER_LITERAL, num: token.num)
    of tkText:     result = Node(nodeType: STRING_LITERAL, str: token.str)
    of tkBool:     result = Node(nodeType: BOOL_LITERAL,   bol: token.bol)
    
    of tkGleich, tkPlus, tkMinus, tkMal, tkDurch, tkModulo:
      result = Node(nodeType: OPERATION, str: $token.tokenType)
    of tkGroesser, tkKleiner:
      result = Node(nodeType: OPERATION, str: $token.tokenType)
      if tokens[index].tokenType == tkGleich:
        result.str &= "gleich"
        inc index
    
    of tkId:
      result = Node(nodeType: IDENTIFIER, str: token.id)
      if token.id in funcs:
        result = Node(nodeType: CALL, info: result)
        
        while tokens[index].tokenType in [tkVon, tkUnd]:
          # Arguments
          inc index
          result.body.add(walk())
        
        if funcs[token.id]["__return_type__"] == VOID: 
          assert tokens[index].tokenType == tkTerm
          inc index  # skip term

    of tkSchreibe:
      result = Node(nodeType: PRINT)
      while tokens[index].tokenType != tkTerm:
        result.body.add(walk())
      inc index  # skip tkTerm

    of tkGib:
      result = Node(nodeType: RETURN)
      while tokens[index].tokenType != tkTerm:
        result.body.add(walk())
      inc index  # skip tkTerm

    of tkParOp:
      result = Node(nodeType: PARENTHESIS)
      while tokens[index].tokenType != tkParCl:
        result.body.add(walk())
      inc index  # skip closing parenthesis

    of tkEingabe:
      result = Node(nodeType: INPUT)
      case tokens[index].tokenType
      # of tkTypBool:     result.d_type = BOOL
      of tkTypText:     result.d_type = TEXT
      of tkTypGanzzahl: result.d_type = INT
      else: raise newException(ValueError, "Invalid data type at $#: $#" % [$token.line, $token])
      inc index 

    of tkMerke:
      result = Node(nodeType: DECLARATION)
      case tokens[index].tokenType
      of tkTypBool:     result.d_type = BOOL
      of tkTypText:     result.d_type = TEXT
      of tkTypGanzzahl: result.d_type = INT
      else: raise newException(ValueError, "Invalid data type at $#: $#" % [$token.line, $token])
      inc index 

      result.info = walk()  # identifier
      assert result.info.nodeType == IDENTIFIER  # TODO assert that new

      case tokens[index].tokenType
      of tkTerm: inc index  # skip term
      of tkAls:
        inc index
        result.body.add(walk())
        assert tokens[index].tokenType == tkTerm
        inc index  # skip term
      else: raise newException(ValueError, "Unexpected token at $#: $#" % [$token.line, $token])

      symbols[result.info.str] = result.d_type

    of tkSetze:
      result = Node(nodeType: ASSIGNMENT)
      result.info = walk()
      assert result.info.nodeType == IDENTIFIER
      assert tokens[index].tokenType == tkAuf
      inc index

      while tokens[index].tokenType != tkTerm:
        result.body.add(walk());
      inc index

    of tkFalls:
      result = Node(nodeType: IF_ELSE_STATEMENT)
      result.info = Node(nodeType: CONDITION)
      while tokens[index].tokenType != tkMach:
        result.info.body.add(walk())
      inc index  # skip mach

      while tokens[index].tokenType notin @[tkOk, tkSonst]:
        result.body.add(walk())
      inc index  # skip ok

      if tokens[index-1].tokenType == tkSonst:
        assert tokens[index].tokenType == tkMach
        inc index  # skip mach
        while tokens[index].tokenType != tkOk:
          result.body_else.add(walk())
        inc index  # skip ok

    of tkSolange:
      result = Node(nodeType: WHILE_STATEMENT)
      result.info = Node(nodeType: CONDITION)
      while tokens[index].tokenType != tkMach:
        result.info.body.add(walk())
      inc index  # skip mach

      while tokens[index].tokenType != tkOk:
        result.body.add(walk())
      inc index  # skip ok

    of tkDefiniere:
      result = Node(nodeType: FUNCTION)
      result.info = walk()  # identifier
      assert result.info.nodeType == IDENTIFIER  # TODO assert that new
      funcs[result.info.str] = Table[string, DataType]()

      echo "deftoke: ", tokens[index]
      while tokens[index].tokenType in [tkVon, tkUnd]:
        # Arguments
        inc index  # skip von/und
        var 
          dtype: DataType
          ident: Node

        case tokens[index].tokenType
        of tkTypBool:     dtype = BOOL
        of tkTypText:     dtype = TEXT
        of tkTypGanzzahl: dtype = INT
        else: raise newException(ValueError, "Invalid data type at $#: $#" % [$token.line, $token])
        inc index  # skip datatype

        ident = walk()
        assert ident.nodeType == IDENTIFIER
        funcs[result.info.str][ident.str] = dtype
        symbols[ident.str] = dtype
        result.args[ident.str] = dtype

      assert tokens[index].tokenType == tkZu
      inc index  # skip zu
      case tokens[index].tokenType
      of tkTypBool:     result.ret = BOOL
      of tkTypText:     result.ret = TEXT
      of tkTypGanzzahl: result.ret = INT
      of tkTypNichts:   result.ret = VOID
      else: raise newException(ValueError, "Invalid data type at $#: $#" % [$token.line, $token])
      funcs[result.info.str]["__return_type__"] = result.ret
      inc index  # skip datatype

      assert tokens[index].tokenType == tkAls
      inc index  # skip als
      while tokens[index].tokenType != tkOk:
        result.body.add(walk())
      inc index  # skip ok

      echo "New function $# ($#) to $#" % [result.info.str, $result.args, $result.ret]

    else: raise newException(ValueError, "Unexpected token at $#: $#" % [$token.line, $token])

    result.line = token.line
    result.col = token.col
    echo "Got node ", $result.nodeType, " index=", $index, "/", $len(tokens)

  while index < len(tokens):
    result.body.add(walk())
