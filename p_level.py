import sys

if len(sys.argv) != 2:
    print("Usage: python script.py <filename>")
    sys.exit(1)

filename = sys.argv[1]

with open(filename, "rb") as f:
    bytes_data = f.read()

hex_values = [f"0x{b:02x}" for b in bytes_data]
print(",".join(hex_values))