#include <stdint.h>
#include <stdio.h>
#include "dp.h"

// Declare symbols from data.S
extern uint64_t len;
extern int32_t input_1[];
extern int32_t input_2[];
extern int32_t output[];

int main() {
    dot_product(input_1, input_2, output, len);

    // Print first few results for verification
    for (uint64_t i = 0; i < len; i++) {
        printf("output[%llu] = %ld\n", i, output[i]);
    }

    return 0;
}