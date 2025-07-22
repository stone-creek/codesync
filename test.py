import argparse
import subprocess
import os
import sys

# Set up argument parser
parser = argparse.ArgumentParser(description="Run basic tests.")
parser.add_argument("--location", default="workspace", help="Directory with files")
args = parser.parse_args()

def execute_lua(mockups_code, unit_tests, code, test_cases):
    result = subprocess.run(['lua', '-e', mockups_code, '-e', unit_tests, '-e', code, '-e', test_cases], capture_output=True, text=True)
    if result.stderr.strip():
        print("Lua Error:", result.stderr.strip())
        sys.exit(1)  # Exit Python with error code 1, so bash sees failure
    print(result.stdout.strip())

def load(filename):
    result = '\n'
    with open(filename, 'r', encoding='utf-8') as f:
        result += f.read()
    result += '\n'
    return result

def attempt_load_test(filename):
    file_path = os.path.join('test', filename)
    if os.path.isfile(file_path):
        print("Found tests:", file_path)
        return load(file_path)
    return ''

try:
    # Load local files into the dictionary (key=filename)
    for filename in os.listdir(args.location):
        file_path = os.path.join(args.location, filename)
        if os.path.isfile(file_path):
            code = load (file_path)
            execute_lua(
                load('stonecreek-mockups.lua'),
                load('u-test.lua'),
                code,
                attempt_load_test(filename))

except Exception as err:
    print(f"Other error occurred: {err}")


