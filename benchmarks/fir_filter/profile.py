import os
import subprocess
import sys
import re
import matplotlib.pyplot as plt

LENGTHS = [32, 64, 128, 256, 512, 1024, 2048, 4096, 8192]

RV_DIR = "../../riscv"


def main():
    # clean setup directory
    ot_commands = [
        "rm -rf ./temp",
        "mkdir ./temp"
    ]
    for cmd in ot_commands:
        run_with_script(cmd)

    all_success = True

    # store cycle counts for graphing
    cycles_data = {
        "vliw": [],
        "scalar": [],
        "empty": []
    }

    diff_data = {
        "vliw-empty": [],
        "scalar-empty": []
    }

    print("\nLength | VLIW cycles | Scalar cycles | Empty cycles| Scalar - Emp|  VLIW - Emp | Improvement")
    print(  "-------|-------------|---------------|-------------|-------------|-------------|-------------")

    for length in LENGTHS:
        # generate test data and rebuild
        setup_commands = [
            f"python gen_data.py {length} > data.S",
            "make clean && make vliw && make scalar && make empty"
        ]
        for cmd in setup_commands:
            run_with_script(cmd)

        out_dir = os.path.join(os.getcwd(), "temp")

        run_commands = [
            ("vliw",
             f"bazel run :rv32_vliw_sim -- --semihost_arm \"$(realpath ../benchmarks/fir_filter/fir_test_vliw.elf)\""),
            ("scalar",
             f"bazel run :rv32g_sim -- --semihost_arm \"$(realpath ../benchmarks/fir_filter/fir_test_scalar.elf)\""),
            ("empty",
             f"bazel run :rv32g_sim -- --semihost_arm \"$(realpath ../benchmarks/fir_filter/fir_test_empty.elf)\""),
        ]

        # store logs and cycle counts
        cycle_counts = {}

        for tag, cmd in run_commands:
            out_log = os.path.join(out_dir, f"out_{tag}_{length}.log")
            err_log = os.path.join(out_dir, f"err_{tag}_{length}.log")

            merged_log = out_log + ".raw"
            run_with_script(cmd, cwd=RV_DIR, merged_log=merged_log)
            split_logs(merged_log, out_log, err_log)

            # extract cycle count from stderr
            cycle_counts[tag] = extract_cycle_count(err_log)

            # save for graphing
            cycles_data[tag].append(cycle_counts[tag] or 0)

        # compare VLIW vs Scalar outputs
        vliw_file = os.path.join(out_dir, f"out_vliw_{length}.log")
        scalar_file = os.path.join(out_dir, f"out_scalar_{length}.log")
        success = compare_outputs(vliw_file, scalar_file, out_dir, length)
        if not success:
            print(f"RESULT MISMATCH AT LENGTH {length}")
            all_success = False

        diff_data["vliw-empty"].append(cycle_counts["vliw"] - cycle_counts["empty"])
        diff_data["scalar-empty"].append(cycle_counts["scalar"] - cycle_counts["empty"])

        sme = cycle_counts.get('scalar') - cycle_counts.get('empty')
        vme = cycle_counts.get('vliw') - cycle_counts.get('empty')
        imp = (sme-vme)/sme

        # print summary line
        print(f"{length:6} | {cycle_counts.get('vliw','-'):11} | "
              f"{cycle_counts.get('scalar','-'):13} | {cycle_counts.get('empty','-'):11}"
              f" | {sme:11} | {vme:11} | {imp}")

    if not all_success:
        print("\nSome outputs mismatched! Check temp/ for details.")
        sys.exit(1)
    else:
        print("\nAll outputs match successfully!")

    # generate graphs
    plot_cycles(LENGTHS, cycles_data, out_dir)
    plot_data(LENGTHS, diff_data, out_dir)


def run_with_script(cmd, cwd=".", merged_log="script_output.log"):
    wrapped = f'script -q {merged_log} bash -c "{cmd}" >/dev/null 2>&1'
    try:
        subprocess.run(wrapped, shell=True, cwd=cwd, check=True, executable="/bin/bash")
    except subprocess.CalledProcessError as e:
        with open(os.path.join(cwd, "script_runner_errors.log"), "a") as err_f:
            err_f.write(f"Command failed: {cmd}\n{e}\n")


def split_logs(merged_log, out_log, err_log):
    with open(merged_log, "r") as src, \
         open(out_log, "w") as out_f, \
         open(err_log, "w") as err_f:
        for line in src:
            if line.startswith("output["):
                out_f.write(line)
            else:
                err_f.write(line)


def compare_outputs(vliw_file, scalar_file, out_dir, length):
    with open(vliw_file) as f:
        vliw_lines = [l.strip() for l in f if l.startswith("output[")]
    with open(scalar_file) as f:
        scalar_lines = [l.strip() for l in f if l.startswith("output[")]

    if vliw_lines == scalar_lines:
        return True
    else:
        diff_file = os.path.join(out_dir, f"diff_{length}.txt")
        with open(diff_file, "w") as f:
            f.write("VLIW output:\n")
            f.write("\n".join(vliw_lines) + "\n\n")
            f.write("Scalar output:\n")
            f.write("\n".join(scalar_lines) + "\n")
        return False


def extract_cycle_count(err_log_path):
    pattern = re.compile(r"Cycle count\s*=\s*(\d+)")
    with open(err_log_path) as f:
        for line in f:
            m = pattern.search(line)
            if m:
                return int(m.group(1))
    return None


def plot_cycles(lengths, cycles_data, out_dir):
    plt.figure(figsize=(10, 6))
    plt.plot(lengths, cycles_data["vliw"], marker='o', label="VLIW")
    plt.plot(lengths, cycles_data["scalar"], marker='s', label="Scalar")
    plt.plot(lengths, cycles_data["empty"], marker='^', label="Empty")
    plt.xlabel("Length")
    plt.ylabel("Cycle Count")
    plt.title("Cycle Count vs Input Length")
    plt.xscale("log", base=2)
    plt.yscale("log")
    plt.grid(True, which="both", ls="--", lw=0.5)
    plt.legend()
    plt.tight_layout()

    graph_file = os.path.join(out_dir, "cycle_counts.png")
    plt.savefig(graph_file)
    print(f"\nCycle count graph saved to {graph_file}")

def plot_data(lengths, cycles_data, out_dir):
    plt.figure(figsize=(10, 6))
    plt.plot(lengths, cycles_data["vliw-empty"], marker='o', label="VLIW")
    plt.plot(lengths, cycles_data["scalar-empty"], marker='s', label="Scalar")
    plt.xlabel("Length")
    plt.ylabel("Cycle Count (Filter Subroutine)")
    plt.title("Cycle Count vs Input Length")
    plt.xscale("log", base=2)
    plt.yscale("log")
    plt.grid(True, which="both", ls="--", lw=0.5)
    plt.legend()
    plt.tight_layout()

    graph_file = os.path.join(out_dir, "diff_cycle_counts.png")
    plt.savefig(graph_file)
    print(f"\nCycle count diff graph saved to {graph_file}")


if __name__ == "__main__":
    main()
