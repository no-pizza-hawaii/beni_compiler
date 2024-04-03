#[ 
Compiler for the Programming language "Beni's Einzigartige Nichtsnützige Informatik-Sprache" (BENI)

BENICOMPILERBENIC                                              OMPI                                                                          
LerbenicompilerbeN                                            IcompI                                                                         
LerbeniCOMPILerbenI                                            COMP                                                                          
ILerbenI     CompilE                                                                                                                         
  RbeniC     OmpileR     BENICOMPILER     BENI  COMPILER     BENICOM                                                                         
  PilerB     EnicomP   ILerbenicompilER   BeniCOmpilerbeNI   CompilE                                                                         
  RbeniCOMPILerbenI   CompileRBENIcompiLE RbenicompilerbeNI   CompiL                                                                         
  ErbenicompilerBE   NicompiL     ErbeniC OMpilerbenicompilE  RbeniC                                                                         
  OmpilERBENIcompiL  ErbenicoMPILErbenicO   MpilerBENIcompiL  ErbenI                                                                         
  CompiL     ErbeniC OmpilerbenicompileR    BenicO    MpileR  BenicO                                                                         
  MpileR     BenicoM PilerbeNICOMPILERB     EnicoM    PilerB  EnicoM                                                                         
  PilerB     EnicomP IlerbeniC              OmpilE    RbeniC  OmpilE                                                                         
RBenicoMPILERbenicoM PilerbeniC             OmpilE    RbeniC OmpilerB                                                                        
EnicompilerbenicomP   IlerbenicOMPILERB     EnicoM    PilerB EnicompI                                                                        
LerbenicompilerbeN     ICompilerbenicoM     PilerB    EnicoM PilerbeN                                                                        
ICOMPILERBENICOMP        ILERBENICOMPIL     ERBENI    COMPIL ERBENICO                                                                        
                                                                                                                                           
        MPILERBENICOM                                                                   PILE   RBENICO                                           
     MPIlerbenicompiL                                                                  ErbenI  CompilE                                           
   RBenicompilerbeniC                                                                   OMPI   LerbenI                                           
  CompilERBENICOmpilE                                                                          RbenicO                                           
 MpilerB       ENICOM    PILERBENICO       MPILERB    ENICOMP    ILERB   ENICOMPIL    ERBENIC   OmpilE      RBENICOMPILE     RBENI   COMPILERB   
EnicomP                ILerbenicompiLE   RBenicompI  LerbenicOM  PilerBENicompilerB   EnicomP   IlerbE    NIcompilerbeniCO   MpileRBEnicompileR  
BenicoM               PilerbenicompileR BenicompileRBenicompileR BenicompilerbenicoM   PilerB   EnicoM   PilerbeNICOMpilerBE NicompilerbenicompI 
LerbenI               CompilERBENicompI LerbenicompilerbenicompI LErbenicOMPILerbeniC  OmpilE   RbeniC  OmpilerB     EnicomP ILerbeniCOMPIlerbenI
CompilE               RbeniC     OmpilE RbenicOMPilerbeNICompilE  RbenicO     MpilerB  EnicoM   PilerB  EnicompiLERBEnicompI  LerbenI     CompilE
RbenicO               MpileR     BenicO MpileR   BenicO   MpileR  BenicoM     PilerbE  NicomP   IlerbE  NicompilerbenicompI   LerbenI     COMPILE
RbenicO               MpileR     BenicO MpileR   BenicO   MpileR  BenicoM     PilerbE  NicomP   IlerbE  NicompiLERBENICOMP    IlerbeN            
 IcompiL       ERBENI CompiL     ErbenI CompiL   ErbenI   CompiL  ErbeniC    OmpilerB  EnicoM   PilerB  EnicompiL             ErbeniC            
  OmpileRBENICOMpileR BenicoMPILErbeniC OmpilE   RbeniC   OmpilE  RbenicOMPILerbenicO MpilerbE NicompiL ErbenicomP            IlerbeN            
   ICompilerbenicompI LerbenicompilerbE NicomP   IlerbE   NicomP  IlerbenicompilerbE  NicompiL ErbenicO  MpilerbenICOMPILE    RbenicO            
     MPIlerbenicompiL  ERbenicompileRB  EnicoM   PilerB   EnicoM  PilerbenicompilER   BenicomP IlerbenI   COmpilerbenicomP    IlerbeN            
        ICOMPILERBENI    COMPILERBEN    ICOMPI   LERBEN   ICOMPI  LerbeniCOMPILER     BENICOMP ILERBENI     COMPILERBENICO    MPILERB            
                                                                  EnicomP                                                                        
                                                                  IlerbeN                                                                        
                                                                 IcompileR                                                                       
                                                                 BenicompI                                                                       
                                                                 LerbenicO                                                                       
                                                                 MPILERBEN                                                                       

]#

import lexer
import parser
# import transformer
import generator
from std/strutils import `%`
from std/os import paramCount, paramStr, getAppFilename, execShellCmd

# TODO: change back to '!= 2' when fully implemented
if paramCount() != 2:  # 0-indexed element is not counted
    echo "Usage: ", getAppFilename(), " path/to/source.beni path/to/output"
    quit(1)

# try:

# Read input
let input = readFile(paramStr(1))

# Tokenize source code
let tokens: seq[Token] = lexer.tokenize(input)
echo "Tokens:\n", tokens

# Parse into AST
let ast: Node = parse(tokens)
echo "\nAST:\n", $ast

# Analyze and transform AST
#let transform = transform(ast)

# Compile AST to code
let output: string = generate(ast)
echo "\nOutput:\n", output

# Write output
writeFile(paramStr(2) & ".c", output)
discard execShellCmd("gcc $1.c -o $1" % [paramStr(2)])  # run gcc

# except CatchableError:
#   let
#     e = getCurrentException()
#     msg = getCurrentExceptionMsg()
#   echo "Got exception ", repr(e), " with message ", msg
