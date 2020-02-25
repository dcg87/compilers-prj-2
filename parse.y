%{
#include <stdio.h>
#include "attr.h"
#include "instrutil.h"
int yylex();
void yyerror(char * s);
#include "symtab.h"

FILE *outfile;
char *CommentBuffer;
 
%}

%union {Token token;
        regInfo targetReg;
       }

%token PROG PERIOD VAR 
%token INT BOOL PRINT THEN IF DO  
%token ARRAY OF 
%token BEG END ASG  
%token EQ NEQ LT LEQ AND OR TRUE FALSE
%token ELSE
%token WHILE 

/* token means that its a terminal symbol with attributes */
%token <token> ID ICONST 

/*type means that its a nonterminal symbol has attributes*/
%type <targetReg> exp 
%type <targetReg> lhs 
%type <targetReg> stype
%type <targetReg> type
%type <token> idlist

%start program

%nonassoc EQ NEQ LT LEQ GT GEQ 
%left '+' '-' AND
%left '*' OR

%nonassoc THEN
%nonassoc ELSE

%%
program : {emitComment("Assign STATIC_AREA_ADDRESS to register \"r0\"");
           emit(NOLABEL, LOADI, STATIC_AREA_ADDRESS, 0, EMPTY);} 
           PROG ID ';' block PERIOD { }
	;

block	: variables cmpdstmt { }
	;

variables: /* empty */
	| VAR vardcls {  }
	;

vardcls	: vardcls vardcl ';' { }
	| vardcl ';' {  }
	| error ';' { yyerror("***Error: illegal variable declaration\n");}  
	;

vardcl	: idlist ':' type { 
 
    Token* ptr = &$1;
    
  
    SymTabEntry * id = lookup($1.str);

    id->size = $3.size;
    if ($3.type == TYPE_INT)
      setter = 'i';
    else if ($3.type == TYPE_BOOL)
      setter = 'b';
    else {
      printf("Error: fix it.\n");
      exit(-1);
     }
   TypeTheEntries(counter,setter);
   counter += 1;
  }
	;

idlist	: idlist ',' ID {  
  
  
   int new_offset = NextOffset(1);
   
   insert($3.str,TYPE_ERROR,new_offset,counter,1);
   SymTabEntry* id = lookup($3.str);
   $$.str = $3.str;
   $$.next = &$1;
   }
        | ID		{ 
         $$.str = $1.str;
  	 
         $1.next = NULL;
         int new_offset = NextOffset(1);
         //name,type,offset,category,size 
         insert($1.str,TYPE_ERROR,new_offset,counter,1);
   SymTabEntry* id = lookup($1.str);




  }

   ;

type	: ARRAY '[' ICONST ']' OF stype { 
         
         $$.type = $6.type;
         $$.size = $3.num;
                

 }

        | stype { $$.type = $1.type; $$.size = 1; }
	; 
stype	: INT { $$.type = TYPE_INT; }
        | BOOL { $$.type = TYPE_BOOL; }
	;

stmtlist : stmtlist ';' stmt { }
	| stmt { }
        | error { yyerror("***Error: ';' expected or illegal statement \n");}
	;

stmt    : ifstmt { }
	| wstmt { }
	| astmt { }
	| writestmt {   }
	| cmpdstmt { }
	;

cmpdstmt: BEG stmtlist END { }
	;

ifstmt :  ifhead 
          THEN stmt 
  	  ELSE 
          stmt 
	;

ifhead : IF condexp {  }
        ;

writestmt: PRINT '(' exp ')' { int printOffset = -4; /* default location for printing */
  	                         sprintf(CommentBuffer, "Code for \"PRINT\" from offset %d", printOffset);

                                 emitComment(CommentBuffer);
                                 emit(NOLABEL, STOREAI, $3.targetRegister, 0, printOffset);
                                 emit(NOLABEL, 
                                      OUTPUTAI, 
                                      0,
                                      printOffset, 
                                      EMPTY);
                               }
	;

wstmt	: WHILE  {  } 
          condexp {  } 
          DO stmt  {  } 
	;


astmt : lhs ASG exp             { 

	  if (! ((($1.type == TYPE_INT) && ($3.type == TYPE_INT)) || 
	         (($1.type == TYPE_BOOL) && ($3.type == TYPE_BOOL)))) {
                     		    printf("*** ERROR ***: Assignment types do not match.\n"); 
				  }
				  emit(NOLABEL,
                                       STORE, 
                                       $3.targetRegister,
                                       $1.targetRegister,
                                       EMPTY);
                                }
	;

lhs	: ID			{ 
				 /* BOGUS  - needs to be fixed */
                                  int newReg1 = NextRegister();
                                  int newReg2 = NextRegister();
 

	 			  $$.targetRegister = newReg2;
                                   
				  SymTabEntry* id = lookup($1.str);
				  if (id == NULL){
 					printf("Error: '%s' not found\n",$1.str);
					exit(-1);}
    				  $$.type = id->type;
				  emit(NOLABEL, LOADI, id->offset, newReg1, EMPTY);
				  emit(NOLABEL, ADD, 0, newReg1, newReg2);

				 
}                                 
                         	  


                                |  ID '[' exp ']' { 

if ($3.type != TYPE_INT){
  printf("***ERROR***: Array variable %s index type must be integer.\n",$1.str);
}


 } 
                                ;


exp	: exp '+' exp		{ int newReg = NextRegister();
  				  
                                  if (! (($1.type == TYPE_INT) && ($3.type == TYPE_INT))) {
    				    printf("*** ERROR ***: Operator types must be integer.\n");
                                  }
                                  $$.type = $1.type;

                                  $$.targetRegister = newReg;
                                  emit(NOLABEL, 
                                       ADD, 
                                       $1.targetRegister, 
                                       $3.targetRegister, 
                                       newReg);
                                }

        | exp '-' exp		{  int newReg = NextRegister();

                                  if (! (($1.type == TYPE_INT) && ($3.type == TYPE_INT))) {
    				    printf("*** ERROR ***: Operator types must be integer.\n");
                                  }
                                  $$.type = $1.type;

                                  $$.targetRegister = newReg;
                                  emit(NOLABEL, 
                                       SUB, 
                                       $1.targetRegister, 
                                       $3.targetRegister, 
                                       newReg);
}

        | exp '*' exp		{   
	int newReg = NextRegister();
        //lookup exp name 
                                  if (! (($1.type == TYPE_INT) && ($3.type == TYPE_INT))) {
    				    printf("*** ERROR ***: Operator types must be integer.\n");
                                  }

                                  $$.targetRegister = newReg;
                                  emit(NOLABEL, 
                                       MULT, 
                                       $1.targetRegister, 
                                       $3.targetRegister, 
                                       newReg);
}

        | exp AND exp		{  } 


        | exp OR exp       	{  }


        | ID			{ /* BOGUS  - needs to be fixed */
	                          int newReg = NextRegister();
                                  SymTabEntry * id = lookup($1.str);
                                  if (id == NULL) {
				   printf("\n*** ERROR: ***: Variable '%s' not declared \n",$1.str);  				}
 				else{
                                  $$.type = id->type;
	                          $$.targetRegister = newReg;
 				 } 
				  emit(NOLABEL, LOADAI, 0, id->offset, newReg);
                                  
	                       } 


        | ID '[' exp ']'	{ if ($3.type != TYPE_INT){
					printf("Error. Noninteger array subsript.\n"); 
  				  	$$.type = $3.type;		
					 }

 					}

	| ICONST                 { int newReg = NextRegister();
	                           $$.targetRegister = newReg;
				   $$.type = TYPE_INT;
				   emit(NOLABEL, LOADI, $1.num, newReg, EMPTY); }

        | TRUE                   { int newReg = NextRegister(); /* TRUE is encoded as value '1' */
	                           $$.targetRegister = newReg;
				   $$.type = TYPE_BOOL;
				   emit(NOLABEL, LOADI, 1, newReg, EMPTY); }

        | FALSE                   { int newReg = NextRegister(); /* TRUE is encoded as value '0' */
	                           $$.targetRegister = newReg;
				   $$.type = TYPE_BOOL;
				   emit(NOLABEL, LOADI, 0, newReg, EMPTY); }

	| error { yyerror("***Error: illegal expression\n");}  
	;


condexp	: exp NEQ exp		{ if (!($1.type == $3.type)){
      printf("***Error***: Relational operator types do not match.\n"); } 
}
        | exp EQ exp		{  } 

        | exp LT exp		{  }

        | exp LEQ exp		{  }

	| exp GT exp		{  }

	| exp GEQ exp		{  }

	| error { yyerror("***Error: illegal conditional expression\n");}  
        ;

%%

void yyerror(char* s) {
        fprintf(stderr,"%s\n",s);
        }


int
main(int argc, char* argv[]) {

  printf("\n     CS415 Spring 2018 Compiler\n\n");

  outfile = fopen("iloc.out", "w");
  if (outfile == NULL) { 
    printf("ERROR: cannot open output file \"iloc.out\".\n");
    return -1;
  }

  CommentBuffer = (char *) malloc(650);  
  InitSymbolTable();

  printf("1\t");
  yyparse();
  printf("\n");
  
  AllocateSpace();
  PrintSymbolTable();
  
  fclose(outfile);
  
  return 1;
}




