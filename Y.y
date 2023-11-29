%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

#define $$ yyval.nonterm

#define addTab tab($$,1,-1,1)
#define useTab tab($$,0,0,1)
#define delTabOnce tab($$,0,-1,1)
#define delTab tab($$,-1,0,1)

#define addTabSafe tab($$,1,-1,0)
#define useTabSafe tab($$,0,0,0)
#define delTabOnceSafe tab($$,0,-1,0)
#define delTabSafe tab($$,-1,0,0)

#define new(str) strcpy($$, str)
#define cat(str) strcat($$, str)

#define fixFuncArgs new(""); \
	if (funcDecl && varArgStatus == NOT_DEFINED) { \
		cat(") {\n"); \
		varArgStatus = DEFINED; \
	}

extern FILE *yyin, *yyout;
int yylex();
int t = 0;

void tab(char* str, int inc, int exInt, char overwrite) {
	if (overwrite) strcpy(str, "");
	t += inc;
	for (int i = 0; i < t+exInt; i++)
		strcat(str, "\t");
}

typedef enum {
	DEFINED = 0, // Скобка аргументов закрыта
	IN_PROGRESS = 1, // Аргументы в процессе добавления
	NOT_DEFINED = 2 // Транслятор еще не дошел до аргументов (случай когда аргументы не указаны вовсе)
} ArgStatus;
ArgStatus varArgStatus = NOT_DEFINED;

int argCount = 0, funcDecl = 0, handleEOL = 0;
%}

%union {
	char nonterm[1024];
	char term[64];
}

%start START
%type<nonterm> COMMANDS COMMAND TOKEN TYPE EXP CONDITION CYCLE OPERATOR PROGRAM_DEF FUNCTION_DEF ARG_EXP VAR_DEF PRINT
%token<term> DIGIT IDENTIFIER TYPE_DEFINITION COMMENT EOL PROGRAM END_PROGRAM 
%token<term> FUNCTION RETURN END_FUNCTION
%token<term> VAR VAR_ARG END_VAR
%token<term> NOT AND OR
%token<term> INT DOUBLE BOOL TRUE FALSE
%token<term> IF THEN ELSE ELSEIF END_IF
%token<term> ASSIGN EQUAL NEQUAL COMPARE MATH MOD LB RB COMMA
%token<term> FOR TO BY DO END_FOR WHILE END_WHILE REPEAT UNTIL
%token<term> PRINT_BEGIN STRING

%%
START:
	COMMANDS { fprintf(yyout, "%s", $1); }
	;
	
COMMANDS:
	COMMAND {new($1);}
	| COMMANDS COMMAND {new($1); cat($2);}
	;
	
COMMAND:
	PROGRAM_DEF {new($1);}
	| FUNCTION_DEF {new($1);}
	| VAR_DEF {new($1);}
	| EOL {
		if (handleEOL) {new(""); handleEOL = 0;}
		else if (varArgStatus == DEFINED || !funcDecl) {new(";\n");}
		else new(""); }
	| COMMENT { fixFuncArgs; useTabSafe; cat($1); cat("\n"); }
	| PRINT { fixFuncArgs; useTabSafe; cat($1); }
	| CYCLE { fixFuncArgs; cat($1); }
	| CONDITION { fixFuncArgs; cat($1); }
	;
	
PRINT:
	PRINT_BEGIN EXP RB {new("printf(\"%d\", "); cat($2); cat(")");}
	| PRINT_BEGIN STRING RB {new("printf("); cat($2); cat(")");}

PROGRAM_DEF:
	PROGRAM IDENTIFIER {addTab; cat("int main() {\n");}
	| END_PROGRAM {useTab; cat("return 0;\n}");}
	;
	
FUNCTION_DEF:
	FUNCTION IDENTIFIER TYPE_DEFINITION TYPE { 
		addTab;
		cat($4); cat(" "); cat($2); cat("("); 
		funcDecl = 1; varArgStatus = NOT_DEFINED; }
	| RETURN EXP {fixFuncArgs; useTabSafe; cat("return "); cat($2); }
	| VAR_ARG { new(""); varArgStatus = IN_PROGRESS; }
	| END_FUNCTION { delTab; cat("}"); argCount = 0; funcDecl = 0; }
	| END_VAR { 
		new("");
		if (varArgStatus == IN_PROGRESS) cat(") {\n"); 
		argCount = 0; varArgStatus = DEFINED; handleEOL = 1; }
	| VAR {new("");}
	;

VAR_DEF:
	IDENTIFIER TYPE_DEFINITION TYPE ASSIGN EXP { fixFuncArgs; useTabSafe; cat($3); cat(" "); cat($1); cat(" = "); cat($5); }
	| IDENTIFIER TYPE_DEFINITION TYPE { 
		if (funcDecl && varArgStatus == NOT_DEFINED) {
			new(") {\n");
			varArgStatus = DEFINED;
			useTabSafe;
		} else if (varArgStatus == DEFINED) {
			useTab;
		} else {
			new("");
			if (varArgStatus == IN_PROGRESS) {
				argCount++;
				if (argCount > 1) cat(", ");
			} else useTab;
		}
		cat($3); cat(" "); cat($1); }
	| IDENTIFIER ASSIGN EXP { fixFuncArgs; useTabSafe; cat($1); cat("="); cat($3); }

ARG_EXP:
	EXP COMMA ARG_EXP {new($1); cat(", "); cat($3);}
	| EXP {new($1);}
	| {new("");}
	;

CYCLE:
	FOR TOKEN ASSIGN TOKEN TO TOKEN DO { fixFuncArgs; addTabSafe;
		char isId = ($4[0] < 48 || $4[0] > 57) || ($6[0] < 48 || $6[0] > 57);
		char isUp = !isId ? (atol($4) <= atol($6)) : 1;
		cat("for ("); cat($2); cat("="); cat($4); cat(";");
		cat($2); cat(isUp ? "<=" : ">="); cat($6); cat(";");
		cat($2); cat(isUp ? "++) {" : "--) {");
		cat(isId ? " // WARNING: Possible incorrect cycle direction conversion due using variables\n" : "\n");}
	| FOR TOKEN ASSIGN TOKEN TO TOKEN BY TOKEN DO { fixFuncArgs; addTabSafe;
		char isId = ($4[0] < 48 || $4[0] > 57) || ($6[0] < 48 || $6[0] > 57);
		char isUp = !isId ? (atol($4) <= atol($6)) : 1;
		cat("for ("); cat($2); cat("="); cat($4); cat(";");
		cat($2); cat(isUp ? "<=" : ">="); cat($6); cat(";"); 
		cat($2); cat(isUp ? "+=" : "-="); cat($8); cat(") {");
		cat(isId ? " // WARNING: Possible incorrect cycle direction conversion due using variables\n" : "\n");}
	| END_FOR {delTab; cat("}");}
	| WHILE EXP DO { fixFuncArgs; addTabSafe; cat("while ("); cat($2); cat(") {\n"); }
	| END_WHILE {delTab; cat("}");}
	| REPEAT {fixFuncArgs; addTabSafe; cat("do {\n");}
	| UNTIL EXP {delTab; cat("} while ("); cat($2); cat(")"); }
	;

CONDITION:
	IF EXP THEN { fixFuncArgs; addTabSafe; cat("if ("); cat($2); cat(") {\n"); }
	| ELSEIF EXP THEN { delTabOnce; cat("} else if ("); cat($2); cat(") {\n"); }
	| ELSE { delTabOnce; cat("} else {"); cat("\n"); }
	| END_IF { delTab; cat("}");}
	;

EXP:
	LB EXP RB OPERATOR EXP {new("("); cat($2); cat(")"); cat($4); cat($5);}
	| LB EXP RB {new("("); cat($2); cat(")");}
	| TOKEN OPERATOR EXP {new($1); cat($2); cat($3);}
	| NOT EXP { new("!"); cat($2); }
	| TOKEN {new($1);}
	| IDENTIFIER LB ARG_EXP RB {new($1); cat("("); cat($3); cat(")"); }
	;

OPERATOR:
	AND {new("&&");}
	| OR {new("||");}
	| ASSIGN {new("=");}
	| COMPARE {new($1);}
	| EQUAL {new("==");}
	| NEQUAL {new("!=");}
	| MATH {new($1);}
	| MOD {new("%");}
	;

TYPE:
	INT { new("int"); }
	| DOUBLE { new("double"); }
	| BOOL { new("char"); }
	;
	
TOKEN:
	IDENTIFIER {new($1); }
	| TRUE {new("true"); }
	| FALSE {new("false"); }
	| DIGIT {new($1); }
	;
	
%%

int main() {
	yyin = fopen("code.st", "r");
	yyout = fopen("output.c", "w");
	
	if (!yyin || !yyout) {
		printf("File(s) cannot be opened");
		return 1;
	}
	
	fprintf(yyout, "#include <stdio.h>\n#define true 1\n#define false 0\n\n");
	yyparse();
	
	fclose(yyin);
	fclose(yyout);
	return 0;
}
void yyerror(char *s) {
	printf("error: %s", s);
}