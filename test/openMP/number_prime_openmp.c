#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <math.h>

#define MASTER 0
 
int is_prime(long long int num){
	long long int max_divisor, d;
	if(num<1) 
		return 0;
	else if(num==1) 
		return 1;
	else if(num>3){
		if(num%2==0) 
			return 0;
		max_divisor = sqrt(num);
		for(d = 3; d<=max_divisor; d+=2){
			if(num%d==0) return 0;
		}
	}
	return 1;
}

int main(int argc, char *argv[]){
    
    int quant = 1000,                
    //long long int quant = 1000000000,
                    i,
                    sum = 0,
                    tmp;
 
    // comm
    int myid, nthreads = 4;
 
    // split
    int split,
        begin,
        end;
    
    omp_set_dynamic(0);     // Explicitly disable dynamic teams
    omp_set_num_threads(nthreads);
    

    
    /* Fork a team of threads giving them their own copies of variables */
    #pragma omp parallel default(shared) private(myid, split, begin, end, i ) reduction(+:sum)
    {
        
        myid =  omp_get_thread_num();
        
        split = ceil((float)(quant)/nthreads);
        begin = split * myid;
        end = split * (myid+1);
        
            // if happen overflow
        if (end > quant)
            end = quant;
    
        for (i = begin; i < end; ++i){
            if (is_prime(i))
                sum++;
        }
        
    }
    
    printf("\n\nNumber Process %d\n", nthreads);
    printf("%i primes were found between %i and %i\n", sum, 0, quant);

    
    return 0;
}

// gcc number_prime_openmp.c -fopenmp -lm && ./a.out
