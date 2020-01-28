#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include<iostream>
#include "config.cuh"
#include<map>
#include <sstream>
#include <vector>
#include <algorithm> 
#include <cassert>
#define maxWordSize 1024
using namespace std;
vector < string > v1;

/*
 * Mapping function to be run for each input. The input must be read from memory
 * and the the key/value output must be stored in memory at pairs. Multiple
 * pairs may be stored at the next postiion in pairs, but the maximum number of
 * key/value pairs stored must not exceed NUM_KEYS.
 */
__device__ void mapper(input_type *input, KeyValuePair *pairs) {
     pairs->key =0;	
     for(int i=0;input->inputName[i]!='\0';i++)
     {
     	 
     	pairs->value[i] =input->inputName[i];

     }
}

/*
 * Reducing function to be run for each set of key/value pairs that share the
 * same key. len key/value pairs may be read from memory, and the output
 * generated from these pairs must be stored at output in memory.
 */
__device__ void reducer(KeyValuePair *pairs, int len,output_type *output) {

	for(int k=0;k<(len-1);k++)
	{
		int wordCount=0;
		int stringCount=1;
		int size=0;
        int duplicatWordCount=0;
        int duplicateCount=1;

		for(int w=0;((pairs+k)->value[w])!='\0';w++)
		{
			size++;
		}
		for(int l=k+1;l<len;l++)
		{
			wordCount=0;
			for(int m=0;m<size;m++)
			{
				if((((pairs+k)->value[m])==((pairs+l)->value[m])))
				{
					if(((pairs+l)->value[size])!='\0')
					{
                            break;
					}
					else
					{
						wordCount++;
					}
					
				}
				if(size==wordCount)
				{
					stringCount++;
				}
			}
		}
        for(int v=k-1;v>=0;v--)
        {
            duplicatWordCount=0;
            for(int m=0;m<size;m++)
            {
                if((((pairs+k)->value[m])==((pairs+v)->value[m])))
                {
                    if(((pairs+v)->value[size])!='\0')
                    {
                            
                    }
                    else
                    {
                        duplicatWordCount++;
                    }
                    
                }
                if(size==duplicatWordCount)
                {
                    duplicateCount++;
                }
            }

        }
            if(duplicateCount==1)
            {
                    (output+k)->x = stringCount;
                    for(int i=0;((pairs+k)->value[i])!='\0';i++)
                    {
                         (output+k)->y[i] = (pairs+k)->value[i] ;
                    } 
            }
            else
            {
                (output+k)->x = 0;
                for(int i=0;((pairs+k)->value[i])!='\0';i++)
                    {
                         (output+k)->y[i] ='\0';
                    } 
            }

	}
 }

void StringWithoutSigns(char *sign)
{
	int len=strlen(sign);
	if(sign[len-1]>0 && sign[len-1]>32 && sign[len-1]<65)
	{
		sign[len-1]=0;
		StringWithoutSigns(sign);
	}
}
void read_words (FILE *f, map<string, int> &m) 
{
    char x[maxWordSize];
    cout<<"Input Data"<<endl;	
    cout<<"*************************"<<endl;
    while (fscanf(f, " %1023s", x) == 1) 
	{
		StringWithoutSigns(x);
		m[x]++;
		string s = std::string(x);
		v1.push_back( s );
     cout<<s<<endl;
    }
    cout<<"*************************"<<endl;
}

/*
 * Main function that runs a map reduce job.
 */
int main(int argc, char const *argv[]) {
    // Allocate host memory
    size_t input_size = NUM_INPUT * sizeof(input_type);
    size_t output_size = NUM_OUTPUT * sizeof(output_type);
    input_type *input = (input_type *) malloc(input_size);
    output_type *output = (output_type *) malloc(output_size);
    map<string, int> m;
	FILE *inputFile;
    cudaEvent_t start, stop;
    float milliseconds = 0.0f;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
	inputFile = fopen("/home/pavankum.sama/fileInput.txt","r");
	read_words(inputFile, m);


  //  printf("Generating %d Test Points\n", NUM_INPUT);
    for (size_t i = 0; i < NUM_INPUT; i++) {
     
         	string s =v1[i]; 
    	    int n = s.length(); 
          // declaring character array 
          char char_array[n + 1]; 
  
         // copying the contents of the 
        // string to char array 
         strcpy(char_array, s.c_str()); 
	    for (int j = 0; j < n; j++) 
	    {
	    	input[i].inputName[j]=char_array[j];
	    }
    }

   
    cudaEventRecord(start);
     // Run the Map Reduce Job
    runMapReduce(input, output);
    cudaEventRecord(stop);

    // Iterate through the output array
    cout<<"Map Reduce wordCount"<<endl;
    cout<<"*************************"<<endl;
    for (size_t i = 0; i <NUM_OUTPUT; i++) {
        if(output[i].x!=0)
        cout<<"("<<output[i].y<<","<<output[i].x<<")"<<endl;
    }
    cout<<"*************************"<<endl;

    cudaEventElapsedTime(&milliseconds, start, stop);
    cout<<"Kernel Exceuction completed"<<endl; 
    cout<<"GPU Exceution Time is: "<<milliseconds<<" ms"<<endl; 

    // Free host memory
    free(input);
    free(output);

    return 0;
}