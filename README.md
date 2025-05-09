# RVR-Starbug

## MPACT-RiscV

MPACT-RiscV is an implementation of an instruction set simulator for the RiscV
instruction set architecture created using the
[MPACT-Sim](https://github.com/google/mpact-sim) simulator tools and framework,
for which there are tutorials at
[Google for Developers](https://developers.google.com/mpact-sim).

The instruction set is described in a set of `.isa` files, and the instruction
encoding in a corresponding set of `.bin_fmt` files. The instruction semantics
are implemented in a set of of functions distributed over a large set of C++
files `*_instructions.{cc,h}`.

The top level simulator control is implemented in `riscv_top.{cc,h}`, and the
simulators are instantiated from main in `rv{32,64}g_sim.cc`.

## Building

### Bazel

MPACT-Sim utilizes the [Bazel](https://bazel.build/) build system. The easiest
way to install bazel is to use
[Bazelisk](https://github.com/bazelbuild/bazelisk), a wrapper for Bazel that
automates selecting and downloading the right version of bazel. Use `brew
install bazelisk` on macOS, `choco install bazelisk` on Windows, and on linux,
download the Bazelisk binary, add it to your `PATH`, then alias bazel to the
bazelisk binary.

### Java

MPACT-Sim depends on Java, so a reasonable JRE has to be installed. For macOS,
run `brew install java`, on linux `sudo apt install default-jre`, and on Windows
follow the appropriate instructions at [java.com](https://java.com).

### Build and Test

To build the mpact-sim libraries for x86 based processors, use the command
`bazel build ...:all` from the top level directory. To run the tests, use the
command `bazel test ...:all`.

For Apple computers with Arm64 M series chips, use `bazel build --macos_sdk_version=YOUR_SDK_VERSION :all` where YOUR_SDK_VERSION is the
version of the macOS SDK you are using. You can find the version of the SDK by running 'xcodebuild -showsdks' in the terminal. For example, if you are using macOS 15.1, you would run `bazel build --macos_sdk_version=15.1 :all`. The specific simulator we are using for scalar is :rv32g_sim, which is the 32 bit scalar simulator. The 64 bit scalar simulator is :rv64g_sim. The vector simulator is :rv32v_sim and :rv64v_sim for 32 and 64 bit respectively. The VLIW sim is WIP.

To test that everything has built correctly, run the command `bazel run :rv32g_sim -- --semihost_htif "$(realpath ../benchmarks/fir_filter/fir_test.elf)"' and you should see the output "Hello World!" in the terminal.

## Compiling benchmarks
To compile the benchmarks, you need to have the RISC-V toolchain installed. I used the riscv64-unknown-elf-gcc toolchain. You can install it using the following command on mac os using homebrew:
```
brew tap riscv-software-src/riscv
brew install riscv-tools
```
For other platforms, you can use prebuilt binaries from [riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain). If your setup differs, update the GCC_TOOLCHAIN and RISCV_PREFIX variables in the Makefile for teh benchmarks to match your environment. You should be able to run make dump and see the disassembly of the scalar and VLIW implementations.

You will also need Make installed, on most unix systems this is already installed. If you are using Windows, you can use the [GNU Make for Windows](http://gnuwin32.sourceforge.net/packages/make.htm) or install it using [Chocolatey](https://chocolatey.org/) with the command `choco install make`. The makefile is set up to work with the RISC-V toolchain and uses a special linker script link.ld to link the code. The linker script is included in the repository and should not need to be modified and makes sure that the locations of the proper sections are compatible with the simulator. The linker script is used to link the code and create the final binary. There are a lot of different compiler and linker flags in the makefile as well which may need to be customized for your environment but worked for me on Arm64 macOS. I also needed to create a symbolic link in the fir_filter directory to the specs file in the MPACT-RiscV directory. Your mileage may vary on this.
```
ln -s /opt/homebrew/Cellar/riscv-gnu-toolchain/main/riscv64-unknown-elf/lib/rv32imac/ilp32/semihost.specs ./semihost.specs
```

Similar to the Berkeley Saturn project, the test inputs and outputs are defined in the data.S file by the gen_data.py script. You may need to install numpy or use venv to create a virtual environment. The script generates the input and output data for the FIR filter benchmark. The input data is stored in the `data.S` file, which is included in the assembly code for the benchmark.

Sources:
fir_main.c: Main application driver - shared between scalar and VLIW

data.S: RISC-V assembly input data

fir_filter_scalar.c: Scalar FIR filter

fir_filter_vliw.S: VLIW-style FIR filter (assembly)

The following Makefile targets are defined:

make all: Build both scalar and VLIW test binaries

make scalar: Build scalar implementation only

make vliw: Build VLIW implementation only

make dump: Generate .dump disassembly files for both binaries

make clean: Remove build artifacts (*.o, *.elf, *.bin, *.hex, *.dump)

Two ELF binaries are produced:

fir_test_scalar.elf

fir_test_vliw.elf

## Semihosting
MPACT-RiscV supports semihosting, which allows the simulator to communicate with the host and perform syscalls and I/O operations. This is useful for debugging and testing purposes. Without semihosting the simulator will get stuck and stall. The semihosting interface for Arm64 M series chips is --semihost_arm. For example, to run the fir scalar benchmark on the simulator on an Arm64 Apple machine with semihosting, use the command `bazel run :rv32g_sim -- --semihost_arm "$(realpath ../benchmarks/fir_filter/fir_test_scalar.elf)"'
where `fir_test_scalar.elf` is the path to the binary you want to run. The simulator will then execute the binary and provide output to console through the semihosting interface. For this specific benchmark you should see an output as follows:
```
Starting simulation
output[0] = -91
output[1] = -28
...
Simulation done: 0.0 sec
```
