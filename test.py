import argparse
import subprocess
import os
import sys

# Set up argument parser
parser = argparse.ArgumentParser(description="Run basic tests.")
parser.add_argument("--location", default="workspace", help="Directory with files")
args = parser.parse_args()

def execute_lua(mockups_code, code):
    result = subprocess.run(['lua', '-e', mockups_code, '-e', code], capture_output=True, text=True)
    # print(result.stdout.strip())
    if result.stderr.strip():
        print("Lua Error:", result.stderr.strip())
        sys.exit(1)  # Exit Python with error code 1, so bash sees failure

def load(filename):
    result = '\n'
    with open(filename, 'r', encoding='utf-8') as f:
        result += f.read()
    result += '\n'
    return result

try:
    mockups_code = load('test/stonecreek-mockups.lua')
    
    # Load local files into the dictionary (key=filename)
    for filename in os.listdir(args.location):
        file_path = os.path.join(args.location, filename)
        if os.path.isfile(file_path):
            code = load (file_path)
            execute_lua(mockups_code, code)

except Exception as err:
    print(f"Other error occurred: {err}")


