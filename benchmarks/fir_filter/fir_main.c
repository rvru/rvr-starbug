#include <stdint.h>
#include <stdio.h>
#include "fir_filter.h"

// Declare symbols from data.S
extern uint64_t n_samples;
extern uint64_t n_taps;
extern int32_t input_signal[];
extern int32_t fir_coeffs[];
extern int32_t fir_output[];

int main() {
    fir_filter(input_signal, fir_coeffs, fir_output, n_samples, n_taps);

    // Print first few results for verification
    for (uint64_t i = 0; i < n_samples; i++) {
        printf("output[%llu] = %ld\n", i, fir_output[i]);
    }

    return 0;
}
