#include <stdlib.h>
#include <stdio.h>
#include "attr.h"

int main()
{
 SymTabEntry* entry = malloc(sizeof(SymTabEntry));
 struct Node* node;
 InitList(&node);

 append(&node,entry);
 printList(&node);
 DestroyList(&node);
 return 0;
}
