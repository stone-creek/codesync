import argparse
import subprocess
import os
import sys

# Set up argument parser
parser = argparse.ArgumentParser(description="Run basic tests.")
parser.add_argument("--location", default="../workspace", help="Directory with files")
args = parser.parse_args()

env = os.environ.copy()
env["LUA_PATH"] = "../test/_?.lua;../test/?.lua;;"  # the trailing ;; appends defaults

def load(filename):
    result = '\n'
    with open(filename, 'r', encoding='utf-8') as f:
        result += f.read()
    result += '\n'
    return result

mockups_framework = load('../test/_stonecreek-mockups.lua')

def execute_lua(filename, code):
    print(f"Executing: {filename}")
    result = subprocess.run(
        ['lua', '-e', mockups_framework, '-e', code],
        capture_output=True, text=True, env=env)

    if result.stderr.strip():
        print(f"Lua Error on {filename}: {result.stderr.strip()}")
        sys.exit(1)  # Exit Python with error code 1, so bash sees failure

    output = result.stdout.strip()
    if output:
        print(output)

try:
    # Execute each file in the specified location individually

    all_code = ""
    for filename in os.listdir(args.location):
        file_path = os.path.join(args.location, filename)
        if os.path.isfile(file_path):
            code = load (file_path)
            all_code += code

            execute_lua( filename, code)

    # make unit tests available

    # Execute each of the tests
    exceptions = {"_stonecreek-mockups.lua", "_u-test.lua"}
    directory = "../test"
    for filename in os.listdir(directory):
        path = os.path.join(directory, filename)
        if not os.path.isfile(path) or filename in exceptions:
            continue
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()

        print(f"===== Testing test script:{path}")
        code = load(path)
        execute_lua( path, all_code + code)

except Exception as err:
    print(f"Other error occurred: {err}")