if exists("b:current_syntax")
  finish
endif

" Comments
syn match dotenvComment '#.*$'

" Keys
syn match dotenvKey '^\s*[A-Za-z_][A-Za-z0-9_]*' nextgroup=dotenvEquals

" Equals sign
syn match dotenvEquals '=' contained nextgroup=dotenvValue

" Values
syn match dotenvValue '.*$' contained contains=dotenvString,dotenvInterpolation,dotenvBoolean,dotenvAngleBracket,dotenvSquareBracket,dotenvCurlyBracket

" Quoted strings
syn region dotenvString start='"' end='"' contained contains=dotenvInterpolation,dotenvEscape
syn region dotenvString start="'" end="'" contained

" Variable interpolation ${VAR} and $VAR
syn match dotenvInterpolation '\${\w\+}' contained
syn match dotenvInterpolation '\$\w\+' contained

" Escape sequences
syn match dotenvEscape '\\.' contained

" Brackets
syn region dotenvAngleBracket start='<' end='>' contained
syn region dotenvSquareBracket start='\[' end='\]' contained
syn region dotenvCurlyBracket start='{' end='}' contained

" Booleans
syn keyword dotenvBoolean true false contained

hi def link dotenvComment Comment
hi def link dotenvKey Identifier
hi def link dotenvEquals Operator
hi def link dotenvString String
hi def link dotenvInterpolation Special
hi def link dotenvEscape SpecialChar
hi def link dotenvBoolean Boolean
hi def link dotenvAngleBracket Type
hi def link dotenvSquareBracket Function
hi def link dotenvCurlyBracket Keyword

let b:current_syntax = "dotenv"
