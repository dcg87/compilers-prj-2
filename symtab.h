/**********************************************
        CS415  Project 2
        Spring  2018
        Student Version
**********************************************/


#ifndef SYMTAB_H
#define SYMTAB_H

#include <string.h>
#include "attr.h"

/* The symbol table implementation uses a single hash     */
/* function. Starting from the hashed position, entries   */
/* are searched in increasing index order until a         */
/* matching entry is found, or an empty entry is reached. */




extern
SymTabEntry * lookup(char *name);

extern
void  insert(char *name, Type_Expression type, int offset,int category,int size);


extern 
void
TypeTheEntries(const int count,char setter);

extern
void PrintSymbolTable();


#endif
