#ifndef MAP_REDUCE_CUH
#define MAP_REDUCE_CUH
#include<string>
using namespace std;

// Configure GPU parameters
#define GRID_SIZE 1024
#define BLOCK_SIZE 1024

// Set number of input elements, number of output elements, and number of keys
// per input element
#define NUM_INPUT 11
#define NUM_OUTPUT 11
#define NUM_KEYS 1


// Example of custom input type
struct Output {
    int x;
    char y[100];
};
struct Input{
    char inputName[100];
};

// Setting input, output, key, and value types
typedef Input input_type;
typedef Output output_type;
typedef int key_type;
typedef char value_type;


// Do not edit below this line

struct KeyValuePair {
   key_type key;
   value_type value[100];
};

void runMapReduce(input_type *input, output_type *output);

#endif