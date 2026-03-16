"""
Disassemble specific functions (relax, step) from a module for section 2.1 report.
Usage: python dis_funcs.py <path_to_module>
Example: python dis_funcs.py micro/python/relax.py > out/python/relax_funcs_dis.txt
"""
import dis
import importlib.util
import sys

def main():
    if len(sys.argv) < 2:
        print("Usage: python dis_funcs.py <path_to_module>", file=sys.stderr)
        sys.exit(1)
    path = sys.argv[1]
    spec = importlib.util.spec_from_file_location("mod", path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    if hasattr(mod, "relax"):
        print("=== relax ===")
        dis.dis(mod.relax)
    if hasattr(mod, "step"):
        print("=== step ===")
        dis.dis(mod.step)

if __name__ == "__main__":
    main()
