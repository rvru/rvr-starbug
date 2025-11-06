// #include "fir_filter.h"

// #define N_TAPS 16

// void fir_filter(const int32_t *input, const int32_t *coeffs, int32_t *output, uint64_t n_samples, uint64_t n_taps) {
//     for (uint64_t i = 0; i < n_samples; i++) {
//         int64_t acc = 0;

//         #pragma GCC unroll 16
//         for (uint64_t j = 0; j < N_TAPS; j++) {
//             if (i >= j)
//                 acc += (int64_t)input[i - j] * coeffs[j];
//         }
//         output[i] = (int32_t)acc;
//     }
// }

#include "fir_filter.h"
#include <stdint.h>

#define N_TAPS 16

void fir_filter(const int32_t *input, const int32_t *coeffs,
                int32_t *output, uint64_t n_samples, uint64_t n_taps) {

    // Startup region — partial sums until enough samples accumulate
    for (uint64_t i = 0; i < N_TAPS - 1 && i < n_samples; i++) {
        int64_t acc = 0;
        for (uint64_t j = 0; j <= i; j++) {
            acc += (int64_t)input[i - j] * coeffs[j];
        }
        output[i] = (int32_t)acc;
    }

    // Steady-state — fully unrolled, no conditionals
    for (uint64_t i = N_TAPS - 1; i < n_samples; i++) {
        int64_t acc = 0;

        #pragma GCC unroll 16
        for (uint64_t j = 0; j < N_TAPS; j++) {
            acc += (int64_t)input[i - j] * coeffs[j];
        }

        output[i] = (int32_t)acc;
    }
}

