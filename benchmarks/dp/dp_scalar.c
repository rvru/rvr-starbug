#include "dp.h"

void dot_product(const int32_t *input_1, const int32_t *input_2, int32_t *output, uint64_t len) {
    int64_t acc = 0;
    for (uint64_t i = 0; i < len; i++) {
          acc += (int64_t)input_1[i] * input_2[i];
          output[i] = (int32_t) acc;
    }
//    output[i] = (int32_t) acc;
}