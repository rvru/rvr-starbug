#include "fir_filter.h"

void fir_filter(const int32_t *input, const int32_t *coeffs, int32_t *output, uint64_t n_samples, uint64_t n_taps) {
    for (uint64_t i = 0; i < n_samples; i++) {
        int64_t acc = 0;
        for (uint64_t j = 0; j < n_taps; j++) {
            if (i >= j)
                acc += (int64_t)input[i - j] * coeffs[j];
        }
        output[i] = (int32_t)acc;
    }
}
