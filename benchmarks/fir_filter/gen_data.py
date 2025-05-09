# Copyright 2025
#
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Generate input data for FIR filter benchmark
# arg: #input samples

import numpy as np
import sys

def emit(name, array, alignment='8'):
  print(".global %s" % name)
  print(".balign " + alignment)
  print("%s:" % name)
  bs = array.tobytes()
  for i in range(0, len(bs), 4):
    s = ""
    for n in range(4):
      s += "%02x" % bs[i+3-n]
    print("    .word 0x%s" % s)

# Number of input samples
if len(sys.argv) > 1:
  n_samples = int(sys.argv[1])
else:
  n_samples = 64

# Number of FIR filter taps
n_taps = 5

# Generate input signal and FIR coefficients
input_signal = np.random.randint(-100, 100, size=n_samples, dtype=np.int32)
coeffs = np.random.randint(-10, 10, size=n_taps, dtype=np.int32)

# Output placeholder
output = np.zeros(n_samples, dtype=np.int32)

# .data section output
print(".section .data,\"aw\",@progbits")
emit("n_samples", np.array(n_samples, dtype=np.uint64))
emit("n_taps", np.array(n_taps, dtype=np.uint64))
emit("input_signal", input_signal, '32')
emit("fir_coeffs", coeffs, '32')
emit("fir_output", output, '32')
