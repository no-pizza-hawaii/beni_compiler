# Beni's Einzigartige Nichtsnützige Informatik-Sprache (BENI)

This high-tech innovational brand-new programming language is the best language you have ever seen. It is completely written in German language keywords so it is very, very easy to understand if you know German (jaja).

### Features
- "Fail-proof" compiler that translates BENI into native C code *(fail proof iff the programmer does not make mistakes)*
- Similar syntax to C so it was easier for me to translate
- Can be built to any architecture *(as long gcc supports it)*
- No external libraries, functions or files to include for easy dependency management *(none)*
- Reduced instruction set for easy learning *(i was lazy)*
- German keywords because why not (German is a beautiful language)
- Only 3 symbols necessary (!: expression terminator, #: comment initiator, (): for logical parentheses)
- You can improve you logical thinking by finding bugs *(there are many)*
- There could be invalid programs that generate valid C code, just try *(and vice-versa)*
- Executable is heavily optimized due to genius optimizations *(thanks to gcc)*
- Huge room for improvement
- Mostly uncommented code to improve critical thinking of contributers
- No automated tests because that would introduce overhead
- Compiler Written in nim

### How to use

- **Variables** (types = ganzzahl, text or boolsch)
```
merke ganzzahl nummer!      # declare variable int nummer
setze nummer auf 3!         # set variable nummer to 3
setze nummer auf 3 * nummer!
merke text bla als "bla"!   # declare and initialize string blabla to "bla"
merke boolsch ja als wahr!  # declare and initialize bool ja to true
```

- **Input and Output**
```
schreibe "Wie heißt du?"!           # Output to the console
merke text input als eingabe text!  # Read input of type int into variable input
schreibe "Hallo, " input!
```

- **Control Flow**
```
schreibe "Wie viele Fibonacci-Zahlen möchtest du ausgeben?"!
merke ganzzahl nums als eingabe ganzzahl!

merke ganzzahl a als 0!
merke ganzzahl b als 1!
merke ganzzahl c!

# Calculate #nums fibonacci numbers
solange nums groesser 0 mach      # while nums greater than 0
    schreibe a!
    setze c auf a plus b!
    setze a auf b!
    setze b auf c!
    setze nums auf nums minus 1!
ok                               # end while loop
```

```
schreibe "Gebe eine Zahl ein"!
merke ganzzahl zahl!
setze zahl auf eingabe ganzzahl!

falls zahl modulo 2 gleich 0 mach  # if zahl%2 == 0
    schreibe "Zahl ist gerade"!
sonst mach                         # else clause
    schreibe "Zahl ist ungerade"!
ok                                 # end if clause
```

- **main() function is everything that is not in another function**
```
# define function `hello` with argument `string name` and return type void
definiere hallo von text name zu nichts als
    schreibe "Hallo. Wie geht's, " name "?"!
ok

# Main routine
hallo von "Peter"!
hallo von "Heinz"!
hallo von "Gertrude"!
gib 0!    # return statement
```

- **Use Compiler**
```
nimble build beni_compiler
./beni_compiler input_file.beni output_file
./output_file
```

### TODO
- Language variant for German dialects (eg. Bavarian)
- add Metaprogramming and Generics

###### Disclaimer:  *Please not use this for real code, nothing is safe*
###### Disclaimer2: *I do not take any responsibility for accidential seizures while reading the source code* (but I am sorry)