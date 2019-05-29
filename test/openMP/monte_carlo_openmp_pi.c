#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <math.h>


int main(int argc, char *argv[]){
    
    int myid, nthreads = 4;
    double mypi,x, y = 0.0;
    
    double i, cont, NEXP =   700000.0;
    //double i, cont, NEXP =   700000000000.0;


    omp_set_dynamic(0);     // Explicitly disable dynamic teams
    omp_set_num_threads(nthreads);
    
    /* Fork a team of threads giving them their own copies of variables */
    #pragma omp parallel default(shared) private(i, myid,x,y,cont) reduction(+:mypi)
    {
        /* Obtain and print thread id */
        myid =  omp_get_thread_num();
        
        /* A slightly better approach starts from large i and works back */
        for (i = myid + 1; i <= NEXP; i += nthreads) {
            x = ((double)(rand())/RAND_MAX);
            y = ((double)(rand())/RAND_MAX);
            if((pow(x,2) + pow(y,2)) <=1)
                cont+=1;
        }
        mypi = 4.0 * (double) cont / NEXP;
    }
    
    
    printf("\n\nNumber process  %i\n", nthreads);
    printf("pi is approximately %.10f \n", mypi);

    
    return 0;
}

// gcc monte_carlo_openmp.c -fopenmp -lm && ./a.out
