#ifndef FIR_FILTER_H
#define FIR_FILTER_H

#include <stdint.h>

extern void fir_filter(const int32_t *input, const int32_t *coeffs, int32_t *output, uint64_t n_samples, uint64_t n_taps);

#endif // FIR_FILTER_H
