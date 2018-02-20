#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

char** str_split(char* a_str, const char a_delim)
{
    char** result    = 0;
    size_t count     = 0;
    char* tmp        = a_str;
    char* last_comma = 0;

    /* Count how many elements will be extracted. */
    while (*tmp)
    {
        if (a_delim == *tmp)
        {
            count++;
            last_comma = tmp;
        }
        tmp++;
    }

    /* Add space for trailing token. */
    count += last_comma < (a_str + strlen(a_str) - 1);

    /* Add space for terminating null string so caller
       knows where the list of returned strings ends. */
    count++;

    result = (char**)malloc(sizeof(char*) * count);

    if (result)
    {
        size_t idx  = 0;
        char* token = strtok(a_str, ",");

        while (token)
        {
            assert(idx < count);
            *(result + idx++) = strdup(token);
            token = strtok(0, ",");
        }
        assert(idx == count - 1);
        *(result + idx) = 0;
    }

    return result;
}

void copy(char *CH1, char *CH2)
{
 int I;
 I=0;
 while ((CH1[I]=CH2[I]) != '\0')
      I++;
}

int nbre_split(char str[], char*res[],char*delim){
 
     int nbre=0;
     char*token;
     	
         
if ((token = strtok(str, delim)) != NULL) {
    do {
       // printf("Word: \"%s\"\n", token);
       res[nbre]=(char*)malloc(sizeof(char)*12);
		strcpy(res[nbre],token);
		//res[nbre]=token;
       nbre++;
    } while ((token = strtok(NULL, delim)) != NULL);
}
     
return nbre;

}



int main()
{
    char months[] = "JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC";
    char** tokens;
    char ch[150]="131.13 166.26 200.113 3.38176";
    char*result[30];   
    int i,nb;
	printf("months=[%s]\n\n", months);

    tokens = str_split(months, ',');

    if (tokens)
    {
        int i;
        for (i = 0; *(tokens + i); i++)
        {
            printf("month=[%s]\n", *(tokens + i));
            free(*(tokens + i));
        }
        printf("\n");
        free(tokens);
    }
     //nb=nbre_split(ch,result,".,?! ");
nb=nbre_split(ch,result,";?! ");
printf("Nbre de token : %d\n",nb);

for(i=0;i<nb;i++)
printf("chaine %d : %s\n",i,result[i]);

system("PAUSE");
   //getch();
}
