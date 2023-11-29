%{
#include <string.h>
#include "y.tab.h"
%}

%%
"INT" 						{return INT;}
"REAL"|"LREAL" 				{return DOUBLE;}
"BOOL" 						{return BOOL;}
"TRUE"						{return TRUE;}
"FALSE"						{return FALSE;}

"FUNCTION" {return FUNCTION;}
"RETURN" {return RETURN;}
"END_FUNCTION" {return END_FUNCTION;}

"VAR" {return VAR;}
"VAR_ARG" {return VAR_ARG;}
"END_VAR" {return END_VAR;}

"PROGRAM"					{return PROGRAM;}
"END_PROGRAM"				{return END_PROGRAM;}
"IF"						{return IF;}
"THEN"						{return THEN;}
"ELSIF"						{return ELSEIF;}
"ELSE"						{return ELSE;}
"END_IF"					{return END_IF;}

"AND"						{return AND;}
"OR"						{return OR;}
"NOT"						{return NOT;}

"FOR"						{return FOR;}
"TO"						{return TO;}
"DO"						{return DO;}
"BY"						{return BY;}
"END_FOR"					{return END_FOR;}
"WHILE"						{return WHILE;}
"END_WHILE"					{return END_WHILE;}
"REPEAT"					{return REPEAT;}
"UNTIL"						{return UNTIL;}
"END_UNTIL"					{}

"print("					{return PRINT_BEGIN;}
"\"".*"\""					{strcpy(yylval.term, yytext); return STRING;}

","							{return COMMA;}
";"							{return EOL;}
":" 						{return TYPE_DEFINITION;}
":=" 						{return ASSIGN;}
"=" 						{return EQUAL;}
"<>"						{return NEQUAL;}
">="|"<="|">"|"<" 			{strcpy(yylval.term, yytext); return COMPARE;}
"+"|"/"|"*"|"-"				{strcpy(yylval.term, yytext); return MATH;}
"MOD"						{return MOD;}
"("							{return LB;}
")"							{return RB;}

"-"?[0-9]* 					{strcpy(yylval.term, yytext); return DIGIT;}
"-"?[a-zA-Z_]([a-zA-Z_]|[0-9])*			{strcpy(yylval.term, yytext); return IDENTIFIER;}
"//".* 						{strcpy(yylval.term, yytext); return COMMENT;}

[ \n\t]						{}
%%

int yywrap() {return 1;}