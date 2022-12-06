"""
Make texts for Makefile, assuming naming conventions are followed
Copy text printed from terminal directly into Makefile in the appropriate places

>> python3 make_test.py {name}

Arguments:
    name: (str) name of the module you want to test

"""

import sys

def make_test_text(name):
    """
    Assumes that name of test file is "test_{name}.sv" and
    source is "{name}.sv"
    """
    print("")
    print(f"test_{name}: tests/test_{name}.sv hdl/{name}.sv")
    print("    ${IVERILOG} $^ -o" + f" test_{name}.bin" + " && ${VVP}" + f" test_{name}.bin" + " ${VVP_POST}")
    # WAVES
    print("")
    print(f"waves_{name}: test_{name}")
    print(f"     gtkwave {name}.fst -a tests/test_{name}.gtkw")


if __name__ == '__main__':
    make_test_text(sys.argv[1])
