/* This program calculates the initial segmentation of a maximum ball set representing the poral space
a soil sample. I use the GSL mathematical library to diagonalize and calculate the eigenvalues of matrices
when approximating a set of balls by ellisoids.
*/

// Directives de preprocesseur en C.
#include <stdio.h> 
#include<stdlib.h> 
#include<string.h> 
#include <gsl/gsl_math.h>
#include <gsl/gsl_eigen.h>
#define PI 3.14

// structures definition

/* Definition of the structure Image point. At each level of my octree, no image is redefined. At the beginning,
leaf level, the last level of the octree, an image point is represented by a voxel (3D point, center of a ball).
At each higher level when building the octree, an image point will be seen as a set of voxels. */
typedef struct
{ int * etiq ; // Table containing the identifiers of all the balls contained in the image point. With the identifier we will help to find the characteristics of the balls in the structure TabBoule
  int nbre ; //number of ball or center of balls or voxel contained in the point images at a time
  float**matcovp; // Matrix of covariance obtained when approximating the number of balls by an ellipsoid.
 } PointImage ;

 // This structure makes it possible to represent a ball. its center x0, y0, z0 and its radius r0
typedef struct{
float coord[4]; //coord[0]=x0;coord[1]=y0;coord[2]=z0;coord[3]=r0;
}Boule;

/* Structure to represent all the image points of the starting balls at each level of the octree
At each level of the octree, this struture gives another view of the starting ball image. During the construction of the octree
leaf towards the root, a point images consists of a set of voxel or ball or center of balls. So,
at the root of the octree, the images of balls is seen as a single point images containing all the balls or the voxel or center
starting balls*/
typedef PointImage***  Matrice3D;  //tableau a trois dimensions contenant tous les points images. 

/*One-dimensional painting of balls. Use when approximating a set of balls.
At the beginning, the characteristics of all the balls of the initial file are stored here
*/
typedef Boule*  TabBoule;

/* See definition of the Matrix3D structure. We simply add in this structure fields to know
the dimensions for each 3D matrix of a level of the octree. a 3D matrix then becomes a 3D image of point Images
matPixel [i] [j] [k] = ImagePoint, 0 <= i <= dimX, 0 <= j <= dimY, 0 <= k <= dimZ*/ 
typedef struct
{ int dimX ; //Dimension pour l'axe des abscisses
  int dimY ; // dimesion pour l'axe des ordonnées
  int dimZ ; // Dimension pour l'axe ds cotes
  Matrice3D matPixel ;
} Image3D ;

/*Octree data structure. It is a one-dimensional array of 3D images.
An octree is seen as a set of Image3D where each Image3D gives another vision of the original image*/
typedef Image3D* Octree; 

/*Structure to represent the initial regions at the end of the calculations. An initial region may be at the end
either an ellipsoid or a balls.
If it's an ellipsoid, then we need the reduced equation and other characteristics. Its center, its 3 axes
the 3 bases of the 3 axes
coefquad [0] = 1 type of the region to say that it is an ellipsoid; coefquad [0] = 0 to say that it is a ball
The indices 1,2,3 are the coordinates of the center of the ellipsoid.
The indices 4,5,6 are the 3 radii of the 3 axes of the ellipsoid.
the indices 7,8,9 represent the coordinates of the basic vector of the first axis
the indices 10, 11, 12 represent the coordinates of the basic vector of the second axis
the indices 13, 14, 15 represent the coordinates of the basic vector of the third axis
If the region is a ball, then the indices 1,2,3,4 respectively represent the center (1,2,3) and the radius (4) of the ball
*/
typedef struct
{ 
  float*coefquad;
} Region; 



/**
This function takes a string of characters and converts it into a real number
*/  
 float str2num (char * input)
{
    float output;
    char * end;
    output = strtod (input, & end);
return output;
}

/**
This function goes into the initial ball file and retrieves the ball number of the file as well as the dimention of the cubic images
3D initial to create. This image will be at the last level of the octree. An image point at this level is a voxel or 3D point or the center of a ball.
The number of ball and the size of the initial image is in the first line of the file: 600 512.
NB: The size of the image must be a power of 8, because octree. If it was quadtree, power dimension of 4.
*/ 
void nbre_bouleDim(char*cheminfich,int res[2])
{
    FILE*fich; char buf[20];
     char*nbreboule,*dimension;
     float numNbre,numDim;
     	fich =fopen(cheminfich,"r");
     
       		if(fgets(buf,20, fich)!=NULL){
               nbreboule = strtok (buf, " ");
			   dimension = strtok (NULL, " ");
               numNbre=str2num(nbreboule);
			   numDim=str2num(dimension);
			   //printf("Ligne : %d",atoi(buf));
			   }
        	res[0]=numNbre;
			res[1]=numDim;

		fclose(fich);
		
} 

/**
When one wants to build the image points of a higher level of the octree, it is necessary to put all
the balls (identifying balls) that contains its 8 sons who are at the lower level. This function allows you to merge two
array of identifiers. We will go through all the 8 threads of the point images, merge the identifier of the balls two by two which will constitute
the identifier table of the new image point. the result of the merge of tab1 and tab2 is put in
*/ 
void fusion(int nb1,int nb2,int*tab1,int*tab2,int*fus){
int i;

for(i=0;i<nb1;i++) {
 fus[i]=tab1[i];
}
for(i=0;i<nb2;i++) {
 fus[i+nb1]=tab2[i];
}
}


/**
Display the contents of a 3D matrix or 3D image or level of the ellipsoid. for the image of a level of the octree,
we display all the identifiers of all the image points constituting the 3D image
*/
void afficheMatrice3D(Matrice3D M,int dim){

int i,j,k,p;
for(i=0;i<dim;i++){
	 for(j=0;j<dim;j++){
	  for(k=0;k<dim;k++){
	   for(p=0;p<M[i][j][k].nbre;p++){
	    printf("Pour M[%d][%d][%d], id %d = %d\n",i,j,k,p,M[i][j][k].etiq[p]);
	   }
	
	  //M[i][j][k].nbre=0;
	  }
	 }
	
	}

}


void affichePoint3D(PointImage M){

int p;
for( p=0;p<M.nbre;p++){
  printf("id %d = %d\n",p,M.etiq[p]);      
}


}


// Fonctions des approximation


float somme(float *x,int lig){
int i;
float sum=0;
  for (i = 0; i < lig; i++)
  {
   sum = sum + x[i];
   
  }
  return sum;
}


 float moyenne(float *x,int lig){
 return somme(x,lig)/(float)lig;
}

/**
Calcul de la variance de n nombres réels
*/
float variance(float *x,int lig){
float moy;
float sum1=0.0;
int i;

moy=moyenne(x,lig);
for (i = 0; i < lig; i++)
{
	sum1 = sum1 + pow((x[i] - moy), 2);
}
 return (sum1/(float)lig);
}
 
/**
Calcul de l'écart type de n nbres réels
*/ 
float ecart_type(float *x,int lig){
 return sqrt(variance(x,lig));
}


float varpoids(float*X,float*Vol,int lig){
float moy;
float sum1=0.0;
int i;
moy=moyenne(X,lig);
 for (i = 0; i < lig; i++)
{
	sum1 = sum1 + pow((X[i] - moy), 2)*Vol[i];
}
 return (sum1/(float)lig);
}


float covpoids(float*X,float*Y,float*Vol,int lig){

float moy1,moy2;
float sum1=0.0;
int i;

moy1=moyenne(X,lig);
moy2=moyenne(Y,lig);

 for (i = 0; i < lig; i++)
{
	sum1 = sum1 + ((X[i] - moy1)*(Y[i] - moy2))*Vol[i];
}
 return (sum1/lig);
}


 void dispMatrice(float**A,int LIG,int COL){
 int i,j;
 
 printf("\n===> Matrice <===\n");
 
for (i=0;i<LIG;i++)
{
for(j=0;j<COL;j++)
printf("%.2f ", A[i][j]);
printf("\n");
}     

}


void calculMatCovP(float**tabboule,float** MatCovP,int lig){
float*X,*Y,*Z,*Ray,*Vol;
		  
int i;			  
	 
    X= (float *) malloc(lig*sizeof(float));
    Y= (float *)malloc(lig*sizeof(float));
    Z= (float *)malloc(lig*sizeof(float));
    Ray= (float *)malloc(lig*sizeof(float));
    Vol= (float *)malloc(lig*sizeof(float)); 
   
  
  	for(i=0;i<lig;i++){
	
	X[i]=tabboule[i][0];
	Y[i]=tabboule[i][1];
	Z[i]=tabboule[i][2];
	Ray[i]=tabboule[i][3];
	
	Vol[i]=(4.0/3.0)*PI*pow(tabboule[i][3],3);
		
  }
 

MatCovP[0][0]=varpoids(X,Vol,lig);
MatCovP[0][1]=covpoids(X,Y,Vol,lig);
MatCovP[0][2]=covpoids(X,Z,Vol,lig);
MatCovP[1][0]=covpoids(Y,X,Vol,lig);
MatCovP[1][1]=varpoids(Y,Vol,lig);
MatCovP[1][2]=covpoids(Y,Z,Vol,lig);
MatCovP[2][0]=covpoids(Z,X,Vol,lig);
MatCovP[2][1]=covpoids(Z,Y,Vol,lig);
MatCovP[2][2]=varpoids(Z,Vol,lig);


dispMatrice(MatCovP,3,3);
free(X);
free(Y);
free(Z);
free(Ray);
free(Vol);


}

/**
This function takes in an array of balls ID of a point images and extract all the features
of these balls in the table of all the balls. We thus extract these characteristics to perform calculations on all the balls
as the approximation for example.
*/
void extraireBoule(TabBoule tabboules,float**tab,int*tabaux,int nbaux){
int i;

for(i=0;i< nbaux;i++){
tab[i][0]=tabboules[tabaux[i]].coord[0];
tab[i][1]=tabboules[tabaux[i]].coord[1];
tab[i][2]=tabboules[tabaux[i]].coord[2];
tab[i][3]=tabboules[tabaux[i]].coord[3];
}

}


 void additionMatrice(float**A,float**B,int dim)
{     

int i,j;
   for(i=0;i<dim;i++)
   {      for(j=0;j<dim;j++)
		   A[i][j]=A[i][j]+B[i][j];
   }
}


/**
This function uses the GSL library to calculate the eigenvalues of a set of balls. He takes in the
parametre data (data structure manufactured according to the rules of GSL) which contains the weighted covariance matrix of the balls to calculate.
During the diagonalization of the covariance matrix, it returns the matrix of passage of the initial mark to the new mark (mark of
the reduced equation of the ellipsoid), the eigenvalues and the coordinates of the basic vectors of the 3 axes of the ellipsoid
*/
void propre(float*data,float base1[3],float base2[3],float base3[3],float valpro[3],float**pass){
     int i;
  gsl_vector *eval = gsl_vector_alloc (3);
  gsl_matrix *evec = gsl_matrix_alloc (3, 3);
  gsl_eigen_symmv_workspace * w = gsl_eigen_symmv_alloc (3);
  
  gsl_eigen_symmv (data, eval, evec, w);
  gsl_eigen_symmv_free (w);
  gsl_eigen_symmv_sort (eval, evec,GSL_EIGEN_SORT_ABS_ASC);
  

  valpro[0]=gsl_vector_get (eval, 0);
  valpro[1]=gsl_vector_get (eval, 1);
  valpro[2]=gsl_vector_get (eval, 2);

  
  
   for(i = 0; i < 3; i++)
    {
         base1[i]=gsl_matrix_get(evec, i, 0);
         base2[i]=gsl_matrix_get(evec, i, 1);
         base3[i]=gsl_matrix_get(evec, i, 2);
		
		  pass[i][0]=gsl_matrix_get(evec, i, 0);
		  pass[i][1]=gsl_matrix_get(evec, i, 1); 
		  pass[i][2]=gsl_matrix_get(evec, i, 2);
    
    }

  gsl_vector_free (eval);
  gsl_matrix_free (evec);
  }
 

float produitscalaire(float*X, float*Y,int lig)
{
      int i;
      float som=0;
      for(i=0;i<lig;i++)
      som=som+(X[i]*Y[i]);

      return som;
}
 

 float max(float a, float b){
 if(a>=b) return a;
 else return b;
 
 }
 

 float maxtab(float*x,int lig){
 int i;
 float max=x[0];
 for(i=0;i<lig;i++){
  if(x[i]>max) max=x[i];
 }
 //free(x);
return max;
}


// Version adaptée (Ajout du rayon d'une constante)
float rayonEllipsoide(float*x,float * ray,int lig){
 int i;
 float res;
 float * p=(float*)malloc(sizeof(float)*lig);
 for(i=0;i<lig;i++)
 p[i]=max(abs(x[i]+ray[i]),abs(x[i]-ray[i]));
// J'ai ajouter cette constante qui permet d'ameliorer la visualisation. Augmenter le rayon des axes.
 res=maxtab(p,lig);  
 free(p);
 return res ;
 }

 // Version exacte
 float rayonEllipsoide1(float*x,float * ray,int lig){
 int i;
 float res;
 float * p=(float*)malloc(sizeof(float)*lig);
 for(i=0;i<lig;i++)
 p[i]=max(abs(x[i]+ray[i]),abs(x[i]-ray[i]));
 res=maxtab(p,lig);  
 free(p);
 return res ;
 }
 
/**
Cette fonction calcul la transposé d'une matrice 3D
*/
void transpose(float**mat,float**arrT,int lig,int col){

 int i,j;
 for(i=0;i<lig;i++)
 {
  for(j=0;j<col;j++)
  {
   arrT[j][i] = mat[i][j];
  }
 }
}
 

void changebase (float**pass,float ub1[3],float ub2[3],int inverse){

int i,j,k;
float**trans;
float som;


// Nous sommes dans un espace vectoriel V . B1=(i,j,k) et B2=(e1,e2,e3) 
if(inverse != 0){
trans=(float **) malloc(3*sizeof(float*));
    for (j=0; j<3; j++)
        trans[j]=(float *) malloc(3*sizeof(float));

transpose(pass,trans,3,3);
//inv(pass)= transposer de P, car Pass est une matrice orthogonale;

for ( i = 0; i < 3; i++) {
         som=0;
    for ( j = 0; j < 3; j++) {
       som = som+trans[i][j] * ub1[j];
    }
     ub2[i]=som;  

}
for (k=0; k<3; k++){
free(trans[k]);
}
free(trans);
}
else{
  for(i=0;i<3;i++){
     som=0;
    for(j=0;j<3;j++){
     som=som+(pass[i][j]*ub1[j]);
    }      
    ub2[i]=som;              
  }
}
}


void ChangeBaseBoule(float*X,float *Y,float*Z,float*XX,float *YY,float*ZZ,float G[3],float**pass,int lig){
int i;
float ub1[3],ub2[3];

for(i=0;i<lig;i++){
ub1[0]=X[i]-G[0];
ub1[1]=Y[i]-G[1];
ub1[2]=Z[i]-G[2];
changebase(pass,ub1,ub2,1);
 // printf ("base1 = %g\n", ub2[0]);
//   printf ("base2 = %g\n",ub2[1]);
//   printf ("base3 = %g\n", ub2[2]);
   XX[i]=ub2[0];
   YY[i]=ub2[1];
   ZZ[i]=ub2[2];

}

}

/**
This function performs the approximation of n balls TabBoule and returns all the characteristics of the ellipsoide which approximates the ball
The coordinates of the basic vectors of the axes, the radii of the axes, the coordinates of the center and the error of the approximation
*/ 
void approximation(float**tabboule,float** MatCovP,float base1[3],float base2[3],float base3[3],float*Rx,float*Ry,float*Rz,float G[3],float*erreurApp,int lig){
float*X,*Y,*Z,*XX,*YY,*ZZ,*Ray,*Vol;
			  
int col=4,j,i,k;			  
float ** pass;			
 gsl_matrix *data;
 float ub1[3],ub2[3],valpro[3];

 pass=(float **) malloc(3*sizeof(float*));
    for (j=0; j<3; j++)
        pass[j]=(float *) malloc(3*sizeof(float));
		
	 
    X= (float *) malloc(lig*sizeof(float));
    Y= (float *)malloc(lig*sizeof(float));
    Z= (float *)malloc(lig*sizeof(float));
    Ray= (float *)malloc(lig*sizeof(float));
    Vol= (float *)malloc(lig*sizeof(float)); 
	
    XX= (float *) malloc(lig*sizeof(float));
    YY= (float *)malloc(lig*sizeof(float));
    ZZ= (float *)malloc(lig*sizeof(float));
  
   
  	for(i=0;i<lig;i++){
	
	X[i]=tabboule[i][0];
	Y[i]=tabboule[i][1];
	Z[i]=tabboule[i][2];
	Ray[i]=tabboule[i][3];
	
	Vol[i]=(4.0/3.0)*PI*pow(tabboule[i][3],3);
		
  }
 
//Calcul du centre de l'ellipsoide, barycentre des boules
G[0]=produitscalaire(Vol, X, lig)/somme(Vol,lig);
G[1]=produitscalaire(Vol,Y,lig)/somme(Vol,lig);
G[2]=produitscalaire(Vol,Z,lig)/somme(Vol,lig);

data = gsl_matrix_alloc(3, 3);
  
  for(i = 0; i < 3; i++)
        for(j = 0; j < 3; j++)
            gsl_matrix_set(data, i, j, MatCovP[i][j] );
			
propre(data,base1,base2, base3, valpro,pass);     
ChangeBaseBoule(X,Y,Z,XX,YY,ZZ,G,pass, lig); 
for (k=0; k<3; k++){
free(pass[k]);
}
free(pass);

*Rx=rayonEllipsoide(XX,Ray,lig);
*Ry=rayonEllipsoide(YY,Ray,lig);
*Rz=rayonEllipsoide(ZZ,Ray,lig);	
*erreurApp=((4.0/3.0)*PI*(*Rx)*(*Ry)*(*Rz))/somme(Vol,lig);

free(X);
free(Y);
free(Z);
free(XX);
free(YY);
free(ZZ);
free(Ray);
free(Vol);
}


 void ecrire_nbre_regionfichier(int nbreregion){

 char*cheminfich="nbre_regions_initiales.txt";
 FILE*entree;

 entree=fopen(cheminfich,"w");
 fprintf(entree,"%d\n",nbreregion);
 fclose(entree);
 }
 

 void ecrire_regionfichier(float**tabboule,int nbre,float erreur,float*coefquad){
 int i;
 
 char*cheminfich="regions_initiales.txt";
 FILE*entree;

 entree=fopen(cheminfich,"a+");
if (nbre>1)
 fprintf(entree,"%d %g %g;%g;%g;%g;%g;%g;%g;%g;%g;%g;%g;%g;%g;%g;%g\n",nbre,erreur,coefquad[1],coefquad[2],coefquad[3],coefquad[4],coefquad[5],coefquad[6],coefquad[7],coefquad[8],coefquad[9],coefquad[10],coefquad[11],coefquad[12],coefquad[13],coefquad[14],coefquad[15]);
else
fprintf(entree,"%d %g 0\n",nbre,erreur);

 for(i=0;i<nbre;i++){
 fprintf(entree,"%g %g %g %g\n",tabboule[i][0],tabboule[i][1],tabboule[i][2],tabboule[i][3]);
 }
 fclose(entree);
 }
 
 
 
 float distance (Boule b1,Boule b2){
   float dist=0;
dist=sqrt( pow((b2.coord[0]-b1.coord[0]),2)+pow((b2.coord[1]-b1.coord[1]),2)+pow((b2.coord[2]-b1.coord[2]),2));  
return dist;
}

// Fonction de connexité
 
/**
The balls are grouped only unless the approximation error verifies a fixed threshold and the set of balls is related.
This function performs the in-depth traversal of a graph to see if there is a path that passes through all the nodes of a graph.
here our graphs is all of our balls.
*/  
void dfs(int v,int**a,int*reach,int n){
     int i;
     reach[v]=1;
     for(i=1;i<=n;i++)
         if(a[v][i]&&!reach[i]){
           // printf("\n%d->%d",v,i);
            dfs(i,a,reach,n);
            }
 }
 

 int  connexes(int n,float**tabboule){
   int i,j,k,count=0,taille;
   Boule b1,b2;
int**a;
int*reach;
taille=n+1;
reach=(int*)malloc(sizeof(int)*taille);
a=(int**)malloc(sizeof(int*)*taille);
for(i=0;i<taille;i++) 
a[i]=(int*)malloc(sizeof(int)*taille);
//initialisation matrice d'ajacence.
    for(i=1;i<taille;i++)
        for(j=1;j<taille;j++){
        reach[i]=0;
        a[i][j]=0;
        }
		
//Recherche des aretes entre les boules pour remplir la matrice d'adjacence		
	for(i=0;i<taille-1;i++){
	for(j=0;j<taille-1;j++){
	if(i!=j){
	b1.coord[0]=tabboule[i][0];b1.coord[1]=tabboule[i][1];b1.coord[2]=tabboule[i][2];b1.coord[3]=tabboule[i][3];
	b2.coord[0]=tabboule[j][0];b2.coord[1]=tabboule[j][1];b2.coord[2]=tabboule[j][2];b2.coord[3]=tabboule[j][3];
	
	if(distance(b1,b2)<=(tabboule[i][3]+tabboule[j][3])){
	//printf("\nIl y a une arete entre la boule %d et la boule %d\n",i,j);
	a[i+1][j+1]=1;
	}
	}
	}
	}
			
    dfs(1,a,reach,taille-1);
    for(i=1;i<taille;i++)
       if(reach[i])
         count++;
		 
free(reach);
for(k=0;k<taille;k++){ 
free(a[k]);
}
free(a);		 
    if(count==taille-1)
      return 1;
    else
      return 0;
 }
 
/**
Cette fontion calcul la valeur absolue d'un nombre réel
*/  
 float absolue(float val){
 if (val>=0)
 return val;
 else     
 return -(val); 
 }

 
 /**
This function calculates the initial regions. It takes the octree in parameter with the matrix of leaves. Divide octree recursively
following an error riddle. The octree at the start is built (by the other functions) going from the leaf level to the root level.
Each level contains one or more Image points. an Image Point may contain balls or not. We are interested in those that contain
At each level, we calculate all the point images and for each one, we calculate the approximation error that we obtain by approximating
all the balls of the image point by an ellipsoid. After construction, this function is responsible for recursively dividing the octree by going from
the root to the leaf, in search of the image points which will be of the future initial region.
a point images at a level of the octree will be considered if its error verifies the threshold of error that one fixes. Otherwise we divide the image point (
one goes through his points Image fils) to repeat the same verification on his son in a recursive way.

 
*/ 
void  creerRegionInit (Region*listeRegion, Matrice3D M,int profondeur,TabBoule tabboules,int* pos,int ordre, int ligne,int colonne, int cote, Octree octree_courant,float seuil){

 
     
	 // Declaration des variables internes
	     PointImage pointImage;
          int k,p,j;
          int x1,x2,x3,x4,x5,x6,x7,x8,y1,y2,y3,y4,y5,y6,y7,y8,z1,z2,z3,z4,z5,z6,z7,z8; // pour explorer les point images fils
         float base1[3], base2[3], base3[3],G[3];
         float Rx,Ry,Rz,erreurApp;
		 Region reg;
	     float**tabboulePointImage;
		
		 // Condition d'arret de parcourt de l'octree. Cette condition permet de traiter tous les niveau sauf le dernier niveau qui contient les feuille.	
         	 
        if (ordre < profondeur+1){ 
		 //k représente un entrée de la pyramide k=0 à n-1. Le niveau k=0 represente le niveau des feuilles et k=n represente la racine
          k = profondeur-ordre+1;
     // Recuperation du point image à traiter. 
     	  pointImage = octree_courant[k].matPixel[ligne][colonne][cote];
                
				 // On ne traite que les point images qui ont au moins 1 boule. Ceux qui n'ont aucune boule ne nous interesse pas. On les ignore tout simplement 
                if(pointImage.nbre > 0){
				// Ce point image contient plusieurs boules. Donc nous interesse.
				 printf("[%d,%d,%d]  entree pyra : %d ordre : %d profondeur : %d Posregion : %d Nbre Boule : %d\n",ligne,colonne,cote,k,ordre,profondeur,*pos,pointImage.nbre);
				
				//Initialisation matrice devant contenir les boules du point Image. 
				tabboulePointImage=(float **) malloc(pointImage.nbre*sizeof(float*));
				for (p=0; p<pointImage.nbre; p++)
				tabboulePointImage[p]=(float *) malloc(4*sizeof(float));	
					extraireBoule(tabboules,tabboulePointImage,pointImage.etiq,pointImage.nbre);
					
					if(pointImage.nbre > 1){
					//On extraire les boules et procedions à l'approximation pour avoir els caracteristique de l'ellipsoide d'approximation
					// On approxime lorsqu'on a au moins 2 boules
					approximation(tabboulePointImage,pointImage.matcovp,base1,base2,base3,&Rx,&Ry,&Rz,G,&erreurApp,pointImage.nbre);
					 printf("Erreur  : %g \n",absolue(erreurApp-1.0));
					
					
				      //if ( connexes(pointImage.nbre,tabboulePointImage)){
                    //   if(absolue(erreurApp-1.0) <= seuil){
				if ((absolue(erreurApp-1.0) <= seuil)&&(connexes(pointImage.nbre,tabboulePointImage))){
					//  Point image  est une region initiale de type ellipsoide.
                     printf("Region OK : %d\n",*pos);
				   reg.coefquad=(float*)malloc(16*sizeof(float));
				  
				  reg.coefquad[0]=1;
				  reg.coefquad[1]=G[0];
				  reg.coefquad[2]=G[1];
				  reg.coefquad[3]=G[2];
				  reg.coefquad[4]=Rx;
				  reg.coefquad[5]=Ry;
				  reg.coefquad[6]=Rz;
				  reg.coefquad[7]=base1[0];
				  reg.coefquad[8]=base1[1];
				  reg.coefquad[9]=base1[2];
				  reg.coefquad[10]=base2[0];
				  reg.coefquad[11]=base2[1];
				  reg.coefquad[12]=base2[2];
				  reg.coefquad[13]=base3[0];
				  reg.coefquad[14]=base3[1];
				  reg.coefquad[15]=base3[2];
                  listeRegion[*pos]=reg;
	                   *pos=*pos+1;
					 
				// Ajouter les boules formant la region dans le fichier des region initiale qui sera utilisé apres par le programme de croissance de region 	 
                 ecrire_regionfichier(tabboulePointImage,pointImage.nbre,erreurApp,reg.coefquad);
                
                }
                else{
				//Le seuil d'approximation n'est pas verifié. Le point image n'est pas i,e region initiale. On effectue les traitement sur ses fils.
                // On calcul les coordonnees des point image fils du point image en cours de traitement. On appel ensuite recurcivement la fonction de traitement sur ces fils.
            // 000;001,010;011;100,101,110,111 coordonnees des fils d'un point image. Les xi,yi,zi prennent  ces valeurs.     
				      x1 = 2*ligne; y1 = 2*colonne;  z1=2*cote;
                      x2 = 2*ligne; y2 = 2*colonne+1; z2=2*cote;
                      x3 = 2*ligne+1; y3 = 2*colonne; z3=2*cote;
                      x4 = 2*ligne+1; y4 = 2*colonne+1; z4=2*cote;
                      x5 = 2*ligne; y5 = 2*colonne;  z5=2*cote+1;
                      x6 = 2*ligne; y6 = 2*colonne+1; z6=2*cote+1;
                      x7 = 2*ligne+1; y7 = 2*colonne; z7=2*cote+1;
                      x8 = 2*ligne+1; y8 = 2*colonne+1; z8=2*cote+1;

                      //traitement pour les fils
			           creerRegionInit (listeRegion,M,profondeur,tabboules,pos,ordre+1, x1, y1, z1,octree_courant, seuil);
                       creerRegionInit (listeRegion,M,profondeur,tabboules,pos,ordre+1, x2, y2, z2, octree_courant, seuil);
                       creerRegionInit (listeRegion,M,profondeur,tabboules,pos,ordre+1, x3, y3, z3, octree_courant, seuil);
                       creerRegionInit (listeRegion,M,profondeur,tabboules,pos,ordre+1, x4, y4, z4, octree_courant, seuil);
                       creerRegionInit (listeRegion,M,profondeur,tabboules,pos,ordre+1, x5, y5, z5,octree_courant, seuil);
                       creerRegionInit (listeRegion,M,profondeur,tabboules,pos,ordre+1, x6, y6, z6, octree_courant, seuil);
                       creerRegionInit (listeRegion,M,profondeur,tabboules,pos,ordre+1, x7, y7, z7, octree_courant, seuil);
                       creerRegionInit (listeRegion,M,profondeur,tabboules,pos,ordre+1, x8, y8, z8, octree_courant, seuil); 

                }
				} // Fin de la condition de traitement pour un point image avec au moins 2 boules
				else{
				// Le point images a une seuil boules. Donc le point image sera une region de type boules. On garde les caracteristique de la boule
						
							 reg.coefquad=(float*)malloc(5*sizeof(float));
							  reg.coefquad[0]=0;
							  reg.coefquad[1]=tabboulePointImage[0][0];
							  reg.coefquad[2]=tabboulePointImage[0][1];
							  reg.coefquad[3]=tabboulePointImage[0][2];
							  reg.coefquad[4]=tabboulePointImage[0][3];
							   listeRegion[*pos]=reg;
	                           *pos=*pos+1;
							// Ajouter la boule formant la region dans le fichier des region initiale qui sera utilisé apres par le programme de croissance de region 	    
							   ecrire_regionfichier(tabboulePointImage,1,0,reg.coefquad);
							 
				
				}
				/*for (j=0; j<pointImage.nbre; j++){
				free(tabboulePointImage[j]);
				}
				free(tabboulePointImage);*/
				} 

          }// On a traiter ici tous les niveau interne à l'octree, sauf le niveau des feuille.
          else{
                    //traitement du dernier niveau n+1(Les feuilles) 
                    k = profondeur-ordre+1; 
                    pointImage = octree_courant[k].matPixel[ligne][colonne][cote];
				if(pointImage.nbre > 0){
				
				tabboulePointImage=(float **) malloc(pointImage.nbre*sizeof(float*));
				for (p=0; p<pointImage.nbre; p++)
				tabboulePointImage[p]=(float *) malloc(4*sizeof(float));	
					extraireBoule(tabboules,tabboulePointImage,pointImage.etiq,pointImage.nbre);
					// On a supposé qu'il peut arriver qu'une feuille contienne plusieurs boules, dans ce cas les approximer. On generalise donc le traitement.
					// Il sera difficile d'avoir ce genre de situation, puis que les point image d'une feuille contient 1 ou 0 boule
					if(pointImage.nbre > 1){
					
					approximation(tabboulePointImage,pointImage.matcovp,base1,base2,base3,&Rx,&Ry,&Rz,G,&erreurApp,pointImage.nbre);
						printf("Erreur  : %g \n",absolue(erreurApp-1.0));
                    //if ( connexes(pointImage.nbre,tabboulePointImage)){
                   // if(absolue(erreurApp-1.0) <= seuil){
					if ((absolue(erreurApp-1.0) <= seuil)&&(connexes(pointImage.nbre,tabboulePointImage))){
                     printf("Region OK : %d\n",*pos);
				  reg.coefquad=(float*)malloc(16*sizeof(float));
				  reg.coefquad[0]=1;
				  reg.coefquad[1]=G[0];
				  reg.coefquad[2]=G[1];
				  reg.coefquad[3]=G[2];
				  reg.coefquad[4]=Rx;
				  reg.coefquad[5]=Ry;
				  reg.coefquad[6]=Rz;
				  reg.coefquad[7]=base1[0];
				  reg.coefquad[8]=base1[1];
				  reg.coefquad[9]=base1[2];
				  reg.coefquad[10]=base2[0];
				  reg.coefquad[11]=base2[1];
				  reg.coefquad[12]=base2[2];
				  reg.coefquad[13]=base3[0];
				  reg.coefquad[14]=base3[1];
				  reg.coefquad[15]=base3[2];
		
				  listeRegion[*pos]=reg;
	                   *pos=*pos+1;
					      
				ecrire_regionfichier(tabboulePointImage,pointImage.nbre,erreurApp,reg.coefquad);	   
					   
	                  }
                    else {
                         
                         //récupérer les fils et calculer les régions

                        
                          x1 = 2*ligne; y1 = 2*colonne;  z1=2*cote;
                          x2 = 2*ligne; y2 = 2*colonne+1; z2=2*cote;
                          x3 = 2*ligne+1; y3 = 2*colonne; z3=2*cote;
                          x4 = 2*ligne+1; y4 = 2*colonne+1; z4=2*cote;
                          x5 = 2*ligne; y5 = 2*colonne;  z5=2*cote+1;
                          x6 = 2*ligne; y6 = 2*colonne+1; z6=2*cote+1;
                          x7 = 2*ligne+1; y7 = 2*colonne; z7=2*cote+1;
                          x8 = 2*ligne+1; y8 = 2*colonne+1; z8=2*cote+1;


							 tabboulePointImage=(float **) malloc(1*sizeof(float*));
					    	 tabboulePointImage[0]=(float *) malloc(4*sizeof(float));	
					         
							 if(M[x1][y1][z1].nbre!=0){
							 extraireBoule(tabboules,tabboulePointImage,M[x1][y1][z1].etiq,M[x1][y1][z1].nbre);
							 reg.coefquad=(float*)malloc(5*sizeof(float));
							  reg.coefquad[0]=0;
							  reg.coefquad[1]=tabboulePointImage[0][0];
							  reg.coefquad[2]=tabboulePointImage[0][1];
							  reg.coefquad[3]=tabboulePointImage[0][2];
							  reg.coefquad[4]=tabboulePointImage[0][3];
							   listeRegion[*pos]=reg;
	                           *pos=*pos+1;
							   ecrire_regionfichier(tabboulePointImage,M[x1][y1][z1].nbre,0,reg.coefquad);
							 }
							 
							  if(M[x2][y2][z2].nbre!=0){
							 extraireBoule(tabboules,tabboulePointImage,M[x2][y2][z2].etiq,M[x2][y2][z2].nbre);
							 reg.coefquad=(float*)malloc(5*sizeof(float));
							  reg.coefquad[0]=0;
							  reg.coefquad[1]=tabboulePointImage[0][0];
							  reg.coefquad[2]=tabboulePointImage[0][1];
							  reg.coefquad[3]=tabboulePointImage[0][2];
							  reg.coefquad[4]=tabboulePointImage[0][3];
							   listeRegion[*pos]=reg;
	                           *pos=*pos+1;
							   ecrire_regionfichier(tabboulePointImage,M[x2][y2][z2].nbre,0,reg.coefquad);
							 }
							
                               if(M[x3][y3][z3].nbre!=0){
							 extraireBoule(tabboules,tabboulePointImage,M[x3][y3][z3].etiq,M[x3][y3][z3].nbre);
							 reg.coefquad=(float*)malloc(5*sizeof(float));
							  reg.coefquad[0]=0;
							  reg.coefquad[1]=tabboulePointImage[0][0];
							  reg.coefquad[2]=tabboulePointImage[0][1];
							  reg.coefquad[3]=tabboulePointImage[0][2];
							  reg.coefquad[4]=tabboulePointImage[0][3];
							   listeRegion[*pos]=reg;
	                           *pos=*pos+1;
							   ecrire_regionfichier(tabboulePointImage,M[x3][y3][z3].nbre,0,reg.coefquad);
							 }

	                           if(M[x4][y4][z4].nbre!=0){
							 extraireBoule(tabboules,tabboulePointImage,M[x4][y4][z4].etiq,M[x4][y4][z4].nbre);
							 reg.coefquad=(float*)malloc(5*sizeof(float));
							  reg.coefquad[0]=0;
							  reg.coefquad[1]=tabboulePointImage[0][0];
							  reg.coefquad[2]=tabboulePointImage[0][1];
							  reg.coefquad[3]=tabboulePointImage[0][2];
							  reg.coefquad[4]=tabboulePointImage[0][3];
							   listeRegion[*pos]=reg;
	                           *pos=*pos+1;
							   ecrire_regionfichier(tabboulePointImage,M[x4][y4][z4].nbre,0,reg.coefquad);
							 }
							 
							   if(M[x5][y5][z5].nbre!=0){
							 extraireBoule(tabboules,tabboulePointImage,M[x5][y5][z5].etiq,M[x5][y5][z5].nbre);
							 reg.coefquad=(float*)malloc(5*sizeof(float));
							  reg.coefquad[0]=0;
							  reg.coefquad[1]=tabboulePointImage[0][0];
							  reg.coefquad[2]=tabboulePointImage[0][1];
							  reg.coefquad[3]=tabboulePointImage[0][2];
							  reg.coefquad[4]=tabboulePointImage[0][3];
							   listeRegion[*pos]=reg;
	                           *pos=*pos+1;
							   ecrire_regionfichier(tabboulePointImage,M[x5][y5][z5].nbre,0,reg.coefquad);
							 }
							 
							   if(M[x6][y6][z6].nbre!=0){
							 extraireBoule(tabboules,tabboulePointImage,M[x6][y6][z6].etiq,M[x6][y6][z6].nbre);
							 reg.coefquad=(float*)malloc(5*sizeof(float));
							  reg.coefquad[0]=0;
							  reg.coefquad[1]=tabboulePointImage[0][0];
							  reg.coefquad[2]=tabboulePointImage[0][1];
							  reg.coefquad[3]=tabboulePointImage[0][2];
							  reg.coefquad[4]=tabboulePointImage[0][3];
							   listeRegion[*pos]=reg;
	                           *pos=*pos+1;
							 ecrire_regionfichier(tabboulePointImage,M[x6][y6][z6].nbre,0,reg.coefquad);
							 }
							 
							   if(M[x7][y7][z7].nbre!=0){
							 extraireBoule(tabboules,tabboulePointImage,M[x7][y7][z7].etiq,M[x7][y7][z7].nbre);
							 reg.coefquad=(float*)malloc(5*sizeof(float));
							  reg.coefquad[0]=0;
							  reg.coefquad[1]=tabboulePointImage[0][0];
							  reg.coefquad[2]=tabboulePointImage[0][1];
							  reg.coefquad[3]=tabboulePointImage[0][2];
							  reg.coefquad[4]=tabboulePointImage[0][3];
							   listeRegion[*pos]=reg;
	                           *pos=*pos+1;
							   ecrire_regionfichier(tabboulePointImage,M[x7][y7][z7].nbre,0,reg.coefquad);
							 }
							 
							   if(M[x8][y8][z8].nbre!=0){
							 extraireBoule(tabboules,tabboulePointImage,M[x8][y8][z8].etiq,M[x8][y8][z8].nbre);
							 reg.coefquad=(float*)malloc(5*sizeof(float));
							  reg.coefquad[0]=0;
							  reg.coefquad[1]=tabboulePointImage[0][0];
							  reg.coefquad[2]=tabboulePointImage[0][1];
							  reg.coefquad[3]=tabboulePointImage[0][2];
							  reg.coefquad[4]=tabboulePointImage[0][3];
							   listeRegion[*pos]=reg;
	                           *pos=*pos+1;
							   ecrire_regionfichier(tabboulePointImage,M[x8][y8][z8].nbre,0,reg.coefquad);
							 }
							 
							/* free(tabboulePointImage[0]);
							 free(tabboulePointImage);*/

						}
					}else{
						
							 reg.coefquad=(float*)malloc(5*sizeof(float));
							  reg.coefquad[0]=0;
							  reg.coefquad[1]=tabboulePointImage[0][0];
							  reg.coefquad[2]=tabboulePointImage[0][1];
							  reg.coefquad[3]=tabboulePointImage[0][2];
							  reg.coefquad[4]=tabboulePointImage[0][3];
							   listeRegion[*pos]=reg;
	                           *pos=*pos+1;
							 ecrire_regionfichier(tabboulePointImage,1,0,reg.coefquad);
				
				   }
					
				/*for (j=0; j<pointImage.nbre; j++){
				free(tabboulePointImage[j]);
				}
				free(tabboulePointImage);*/
				}

          } 

 }


/** 
Cette fonction permet de construire l'octree des feuille à la racine. Au départ, on construire d'abord à l'image initiales , apres l'octree
avec les autre point images.
*/
Octree construitOctree (Matrice3D M,TabBoule tabboules, int nbligne){



         Octree octree_courant;// octree à construire
         int profondeur;// nombre de niveau de l'octree
         int ind;//indexation des niveau de l'octree
         Matrice3D m1;//matrice auxilaire
         int dimX,dimY,dimZ;// dimension de la matrice image pour chaque les niveau de l'octree
         int i,j,k,p; 
         PointImage *pointImages; // Va nous permettre à recuperer les identifiant des boules d'un point image parent
		 int*tabaux,*tabaux1;
		 int nbaux=0;
		 float**tabboulePointImage;


         
         profondeur=(int)ceil((log(nbligne)/(log(2))));
         octree_courant=(Octree)malloc(sizeof(Image3D)*profondeur);


         ind=0;
         m1=M;
         dimX=nbligne;
         dimY=nbligne;
         dimZ=nbligne;
         pointImages=(PointImage*)malloc(sizeof(PointImage)*8);
		 //Construction des niveau de la pyramide.
             while (ind<profondeur){
                    // positionnement des dimensions de la matrice image du niveau
                     octree_courant[ind].dimX=dimX/2;
                     octree_courant[ind].dimY=dimY/2;
                     octree_courant[ind].dimZ=dimZ/2;
                     octree_courant[ind].matPixel=(PointImage***)malloc(sizeof(PointImage)*(octree_courant[ind].dimX));
                     for(i=0;i<octree_courant[ind].dimY;i++){
                         octree_courant[ind].matPixel[i]=(PointImage**)malloc(sizeof(PointImage)*octree_courant[ind].dimY);
                     }
                    for(i=0;i<octree_courant[ind].dimX;i++){
                        for(j=0;j<octree_courant[ind].dimY;j++){
                            octree_courant[ind].matPixel[i][j]=(PointImage *)malloc(sizeof(PointImage)*octree_courant[ind].dimZ);
                        }
                    }

					 //initialisation de la nouvelle matrice image
					 for(i=0;i<dimX/2;i++){
					 for(j=0;j<dimY/2;j++){
					  for(k=0;k<dimZ/2;k++){
					  octree_courant[ind].matPixel[i][j][k].nbre=0;
					 
					  }
					 }
					
					}
					
		
                     for(i=0;i<dimX/2;i++){
                         for(j=0;j<dimY/2;j++){
					        for(k=0;k<dimZ/2;k++){
							 
							 	 nbaux=0;
                                pointImages[0]= m1[2*i][2*j][2*k];
                                pointImages[1]= m1[2*i][2*j+1][2*k];
                                pointImages[2]= m1[2*i+1][2*j][2*k];
                                pointImages[3]= m1[2*i+1][2*j+1][2*k];
                                pointImages[4]= m1[2*i][2*j][2*k+1];
                                pointImages[5]= m1[2*i][2*j+1][2*k+1];
                                pointImages[6]= m1[2*i+1][2*j][2*k+1];
                                pointImages[7]= m1[2*i+1][2*j+1][2*k+1];

								for(p=0;p<=7;p++){
									if(pointImages[p].nbre > 0){
									  if(nbaux==0){
									  tabaux=(int*)malloc(sizeof(int)*pointImages[p].nbre);
									  tabaux=pointImages[p].etiq;
									  nbaux=pointImages[p].nbre;
									  }else{
									  tabaux1=(int*)malloc(sizeof(int)*(nbaux+pointImages[p].nbre));
									  fusion(pointImages[p].nbre,nbaux,pointImages[p].etiq,tabaux,tabaux1);
									  tabaux=(int*)malloc(sizeof(int)*(nbaux+pointImages[p].nbre));
									  tabaux=tabaux1;
									  nbaux=nbaux+pointImages[p].nbre;
									  }
							         }
								
								}
								//free(pointImages);
								if(nbaux!=0){
                              printf("%i %i  %i  ind: %i T:%i Nbre : %d\n",i,j,k,ind,profondeur,nbaux);
								octree_courant[ind].matPixel[i][j][k].etiq=(int*)malloc(sizeof(int)*nbaux);
								octree_courant[ind].matPixel[i][j][k].etiq=tabaux;
                                octree_courant[ind].matPixel[i][j][k].nbre=nbaux;
                             
							  //calcul de la matrice de covariance pondéré de ce point image s'il plusieurs boules
							  if(nbaux > 1){
							  //initialise structure matrice covariance
							  octree_courant[ind].matPixel[i][j][k].matcovp=(float **) malloc(3*sizeof(float*));
								for (p=0; p<3; p++)
									octree_courant[ind].matPixel[i][j][k].matcovp[p]=(float *) malloc(3*sizeof(float));
								//Initialisation matrice devant contenir les boules du point Image
								tabboulePointImage=(float **) malloc(nbaux*sizeof(float*));
								for (p=0; p<nbaux; p++)
								tabboulePointImage[p]=(float *) malloc(4*sizeof(float));	
									extraireBoule(tabboules,tabboulePointImage,tabaux,nbaux);
									calculMatCovP(tabboulePointImage,octree_courant[ind].matPixel[i][j][k].matcovp,nbaux);
									     
                              }	
							}		
                                
                             }
                         }
                     }

                     m1=octree_courant[ind].matPixel;
                     dimX=octree_courant[ind].dimX;
                     dimY=octree_courant[ind].dimY;
                     dimZ=octree_courant[ind].dimZ;
                     ind=ind+1;
         }

        return octree_courant;
 }


 /**
 Cette fonction écrit les caracteristiques des regions type ellipsoide et boules dans un fichier. Ce fichier sera utilisé apres par 
 des fontion Matlab pour visualiser les resultats de la segmentation initiales sur un fichier de boules
 */
void ecrireRegionFichier(char*cheminfich,Region*listeRegion,int nbreRegion){
int i,j;
FILE*entree;
float n;
entree=fopen(cheminfich,"w");

for(i=0;i<nbreRegion;i++){

	if(listeRegion[i].coefquad[0]==1){
	//printf("Coefficient Region : %d . Type Region : Ellipsoide\n\n",i);
	for(j=0;j<16;j++){
	//printf(" param %d = %g ; ",j, listeRegion[i].coefquad[j]);
	fprintf(entree,"%g ",listeRegion[i].coefquad[j]);
	}
	fprintf(entree,"\n");
	//printf("\n\n");
	}else{
	//printf("Coefficient Region : %d . Type Region : Boules\n\n",i);
	for(j=0;j<5;j++){
	//printf(" param %d = %g ; ",j, listeRegion[i].coefquad[j]);
	fprintf(entree,"%g ",listeRegion[i].coefquad[j]);
	}
	fprintf(entree,"\n");
	//printf("\n\n");
	}

}
fclose(entree);

}

/**cette fonction construit à base du fichier de boules, l'images des coordonnees des boule et le tableau des caracteristique des boules
*/
void construitMatriceSommet (Matrice3D M,TabBoule tabboules,char*cheminfich,int*dim1,float erreurdecoupage){
int nbreboule_dim[2];
int nbreboule;
int dim, i,j,k,nblig=0;
float numx0,numy0,numz0,numray;
Region*listeRegion;
FILE*fich;  
char buf[100];
char*x0,*y0,*z0,*ray;
Octree octree_courant;
int*pos;
int nbreNiveau;
nbre_bouleDim(cheminfich,nbreboule_dim);
nbreboule=nbreboule_dim[0];
dim=nbreboule_dim[1];
*dim1=dim;

    //initialisation de la nouvelle matrice
    M=(PointImage ***)malloc(dim*sizeof(PointImage));
    for(i=0;i<dim;i++){
        M[i]=(PointImage **)malloc(dim*sizeof(PointImage));
    }
    for(i=0;i<dim;i++){
        for(j=0;j<dim;j++){
            M[i][j]=(PointImage *)malloc(dim*sizeof(PointImage));
        }
    }
	//initialisation du tableau devant contenir les caracteristique des boules
	printf("Nbre de boules réelle : %d et dimension : %d",nbreboule,dim);
	tabboules=(Boule *)malloc(nbreboule*sizeof(Boule));
	
	
	//Initialisation de la structure matrice 3D initiale avec les valeurs par défaut
	for(i=0;i<dim;i++){
	 for(j=0;j<dim;j++){
	  for(k=0;k<dim;k++){
	  M[i][j][k].nbre=0;
	  }
	 }
	
	}

	
//Lecture du fichier de boule et remplissage des structure Images et Tableau de sommet
fich =fopen(cheminfich,"r");
   
       		while (fgets(buf,100, fich)!=NULL){
                    	nblig=nblig+1;
                if(nblig>1){
                     	 	//printf("\n %s \n",buf);
             	 	x0 = strtok (buf, " ");
                  	y0 = strtok (NULL, " ");
                  	z0 = strtok (NULL, " ");
					ray = strtok (NULL, " ");
                
					numx0=str2num(x0);
					numy0=str2num(y0);
					numz0=str2num(z0);
					numray=str2num(ray);
					
					//i=ceil(numx0);
					i=floor(numx0);
					j=floor(numy0);
					k=floor(numz0);
		  	
         		M[i][j][k].nbre=1;
				M[i][j][k].etiq=(int *)malloc(sizeof(int));
				M[i][j][k].etiq[0]=nblig-2;
				//printf(" Etiq M[%d][%d][%d] =  %d\n",i,j,k,M[i][j][k].etiq[0]);
				
				
				tabboules[nblig-2].coord[0]=numx0;
				 tabboules[nblig-2].coord[1]=numy0;
				 tabboules[nblig-2].coord[2]=numz0;
				 tabboules[nblig-2].coord[3]=numray;

                   }	
             
                  }
        	


		fclose(fich);
			printf("\n Nombre de ligne : %d\n",nblig);
		system("PAUSE");
    	
		//Construction de l'octree courant
		 octree_courant = construitOctree(M,tabboules,dim);
		 listeRegion=(Region *)malloc(nbreboule*sizeof(Region));
		 pos=(int*)malloc(sizeof(int));
		 pos[0]=0;
		 nbreNiveau=ceil(log(dim)/log(2));
		 system("PAUSE");
		 //Construction des region initiales à partie de l'octree
       	 creerRegionInit(listeRegion,M,nbreNiveau,tabboules,pos,2, 0,0, 0, octree_courant,erreurdecoupage);
     printf("FIN CONSTRUCTION REGIONS INITIALE. Nombre de region : %d Nbre Niveau : %d\n",*pos,nbreNiveau);
	 ecrireRegionFichier("resultat_region_init.txt",listeRegion,*pos);
	 ecrire_nbre_regionfichier(*pos);
	 
  
  
    for(i=0;i<dim;i++){
        for(j=0;j<dim;j++){
            free(M[i][j]);  
        }
    }	
	 for(i=0;i<dim;i++){
        free(M[i]);
    }	
free(M);
free(tabboules);
free(octree_courant);
free(listeRegion);

}



int main(){


int*dim;
//char*cheminfich="c:/all/boule1.txt";
//char*cheminfich="c:/all/sand2.bmax";
//char*cheminfich="../128x128.bmax";
//char*cheminfich="../Nouvelles/p1l.bmax";
char*cheminfich="../Nouvelles/p4l.br";
//char*cheminfich="../256x256.bmax";;
Matrice3D Mat;
TabBoule tab;
system("del regions_initiales.txt");		
//Erreur ok : 0,7
construitMatriceSommet ( Mat,tab,cheminfich,&dim,0.8);

getch();
}

