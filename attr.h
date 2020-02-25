/**********************************************
        CS415  Project 2
        Spring  2015
        Student Version
**********************************************/

#ifndef ATTR_H
#define ATTR_H

#include <stdlib.h>
#include <stdio.h>



static int counter = 0;
static int setter = 0;
/* num is for ICONST; str is for id */
typedef union {int num; char *str; } tokentype;
typedef enum type_expression {TYPE_INT=0, TYPE_BOOL, TYPE_ERROR} Type_Expression;

typedef struct {
        Type_Expression type;
        int targetRegister;
        int size;
        } regInfo;

typedef struct Token {
char* str;
int num;
struct Token* next;
}Token;


typedef struct SymTabEntry{ /* need to augment this */
  char *name;
  int offset;
  Type_Expression type;  
  int category;
  int size; 
} SymTabEntry;



#endif


  
