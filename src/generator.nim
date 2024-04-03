#[ 

BeniCompilerBeniC                                           ompi                                                                          
l::::::::::::::::e                                         r::::B                                                                         
e::::::niComp:::::i                                         lerB                                                                          
en:::::i     C:::::o                                                                                                                      
  m::::p     i:::::l    erBeniCompil    erBe  niCompil    erBeniC                                                                         
  o::::m     p:::::i  le::::::::::::rB  e:::ni::::::::Co  m:::::p                                                                         
  i::::lerBen:::::i  C::::::ompil:::::erB::::::::::::::en  i::::C                                                                         
  o:::::::::::::mp  i::::::l     e:::::rBe:::::::::::::::n i::::C                                                                         
  o::::mpiler:::::B e:::::::niCom::::::p  i:::::lerB:::::e n::::i                                                                         
  C::::o     m:::::pi:::::::::::::::::l   e::::r    B::::e n::::i                                                                         
  C::::o     m:::::pi::::::lerBeniComp    i::::l    e::::r B::::e                                                                         
  n::::i     C:::::om:::::::p             i::::l    e::::r B::::e                                                                         
ni:::::Compil::::::er::::::::B            e::::n    i::::Co::::::m                                                                        
p:::::::::::::::::i  l::::::::erBeniCo    m::::p    i::::le::::::r                                                                        
B::::::::::::::::e    ni:::::::::::::C    o::::m    p::::il::::::e                                                                        
rBeniCompilerBeni       CompilerBeniCo    mpiler    BeniCompilerBe                                                                        
                                                                                                                                        
        niCompilerBen                                                               iCom  pilerBe                                         
     niC::::::::::::o                                                              m::::p i:::::l                                         
   er:::::::::::::::B                                                               eniC  o:::::m                                         
  p:::::ilerBeni::::C                                                                     o:::::m                                         
 p:::::i       lerBen   iCompilerBe      niCompi    lerBeni   Compi   lerBeniCo   mpilerB  e::::n     iCompilerBen    iComp   ilerBeniC   
o:::::m               pi:::::::::::le  rB:::::::e  n:::::::iC o::::mpi:::::::::l  e:::::r  B::::e   ni::::::::::::Co  m::::pil:::::::::e  
r:::::B              e:::::::::::::::ni::::::::::Co::::::::::mp:::::::::::::::::i  l::::e  r::::B  e::::::niCom:::::pil:::::::::::::::::e 
r:::::B              e:::::niCom:::::pi::::::::::::::::::::::ler::::::BeniC::::::o m::::p  i::::l e::::::r     B:::::eni::::::Compi::::::l
e:::::r              B::::e     n::::iC:::::omp::::::ile:::::r B:::::e     n:::::i C::::o  m::::p i:::::::lerBe::::::n i:::::C     o:::::m
p:::::i              l::::e     r::::Be::::n   i::::C   o::::m p:::::i     l:::::e r::::B  e::::n i:::::::::::::::::C  o:::::m     pilerBe
n:::::i              C::::o     m::::pi::::l   e::::r   B::::e n:::::i     C:::::o m::::p  i::::l e::::::rBeniCompil   e:::::r            
 B:::::e       niCompi::::l     e::::rB::::e   n::::i   C::::o m:::::p    i::::::l e::::r  B::::e n:::::::i            C:::::o            
  m:::::pilerBen::::iC:::::ompil:::::er::::B   e::::n   i::::C o:::::mpile:::::::rB::::::en::::::iC::::::::o           m:::::p            
   il:::::::::::::::er:::::::::::::::Be::::n   i::::C   o::::m p::::::::::::::::i l::::::er::::::B e::::::::niCompil   e:::::r            
     Ben::::::::::::i Co:::::::::::mp i::::l   e::::r   B::::e n::::::::::::::iC  o::::::mp::::::i  le:::::::::::::r   B:::::e            
        niCompilerBen   iCompilerBe   niComp   ilerBe   niComp i::::::lerBeniC    ompilerBeniCompi    lerBeniCompile   rBeniCo            
                                                               m:::::p                                                                    
                                                               i:::::l                                                                    
                                                              e:::::::r                                                                   
                                                              B:::::::e                                                                   
                                                              n:::::::i                                                                   
                                                              CompilerB                                                                   

]#

import parser
import std/strutils
import std/sequtils
import std/tables

var
  uses_print: bool = false
  uses_input: bool = false
  uses_bool:  bool = false

proc generateArgs(args: Table[string, DataType]): string =

  for k in args.keys:
    if k == "__return_type__": continue
    case args[k]:
    of INT: result  &= "int " & k & ","
    of TEXT: result &= "char* " & k & ","
    of BOOL: result &= "bool " & k & ","
    else: discard
  
  if len(result) > 2:
    result = result[0..^2]  # cut of last two comma `,`

proc generateC(node: Node): string =
  case node.nodeType:
  of PROGRAM:
    result = node.body.filter(proc (node: Node): bool = node.nodeType == FUNCTION).map(generateC).join("\n")
    if node.body.filter(proc (node: Node): bool = node.nodeType != FUNCTION).len() > 0:
      result &= "int main() {\n"
      result &= node.body.filter(proc (node: Node): bool = node.nodeType != FUNCTION).map(generateC).join("\n")
      result &= "\n}"

  of STRING_LITERAL: return "\"$#\"" % [node.str] 
  of IDENTIFIER:     return node.str
  of NUMBER_LITERAL: return $node.num
  of BOOL_LITERAL:
    uses_bool = true 
    return $node.bol
  of PARENTHESIS:    return "($#)" % node.body.map(generateC).join(" ")
  
  of PRINT:
    uses_print = true
    for n in node.body:
      if n.nodeType == NUMBER_LITERAL or 
      (n.nodeType == IDENTIFIER and symbols[n.str] == INT) or
      (n.nodeType == CALL and funcs[n.info.str]["__return_type__"] == INT):
        result &= "printf(\"%d\", $#); " % generateC(n)
      else: result &= "printf($#); " % generateC(n)
    # for b in node.body.map(generateC):
    #   result &= "printf(" & b & "); "
    result &= "printf(\"\\n\");"

  of RETURN:
    result = "return " & node.body.map(generateC).join(" ") & ";"

  of DECLARATION:
    case node.d_type:
    of INT: result  &= "int "
    of TEXT: result &= "char* "
    of BOOL: result &= "bool "
    else: discard

    result &= generateC(node.info)
    # if node.d_type == TEXT:
    #   result &= "[100]"  # TODO 
    if node.body.len() > 0:
      result &= " = " & generateC(node.body[0])
    result &= ";"

  of ASSIGNMENT:
    return generateC(node.info) & " = " & node.body.map(generateC).join(" ") & ";"

  of INPUT:
    case node.d_type:
    of INT: result  &= "readInt()"
    of TEXT: result &= "readStr(100)"
    else: discard
    uses_input = true
    uses_print = true  # for scanf

  of IF_ELSE_STATEMENT:
    result &= "if ($#) { $# } else { $# } " % [
      node.info.body.map(generateC).join(" "), 
      node.body.map(generateC).join("\n"), 
      node.body_else.map(generateC).join("\n")]

  of WHILE_STATEMENT:
    result &= "while ($#) { $# }" % 
      [node.info.body.map(generateC).join(" "), node.body.map(generateC).join("\n")]

  of OPERATION:
    case node.str:
    of "plus": return "+"
    of "minus": return "-"
    of "mal": return "*"
    of "durch": return "/"
    of "modulo": return "%"
    of "groesser": return ">"
    of "kleiner": return "<"
    of "groessergleich": return ">="
    of "kleinergleich": return "<="
    of "gleich": return "=="

  of FUNCTION:
    case node.ret:
    of INT: result  &= "int "
    of TEXT: result &= "char* "
    of BOOL: result &= "bool "
    of VOID: result &= "void "    

    result &= "$#($#) { $# } " % [node.info.str, node.args.generateArgs(), node.body.map(generateC).join("\n")]

  of CALL:
    result &= "$#($#)" % [node.info.str, node.body.map(generateC).join(", ")]
    if funcs[node.info.str]["__return_type__"] == VOID:
      result &= ";"
  
  else: raise newException(ValueError, "Invalid node type " & $node.nodeType)

proc generate*(node: Node): string =
  result = generateC(node)

  if uses_input:
    result = "int readInt() { int n; scanf(\"%d\", &n); return n; } \n" & result
    result = "char* readStr(int len) { char* s = (char*) malloc((len+1) * sizeof(char)); scanf(\"%s\", s); return s; } \n" & result
    result = "#include <stdlib.h>\n" & result  # malloc
    uses_input = false

  if uses_print:
    result = "#include <stdio.h>\n" & result
    uses_print = false  # reset

  if uses_bool:
    result = "#include <stdbool.h>\n" & result
    uses_bool = false  # reset