# Stone Creek CodeSync

This tool is used to help manipulate class (ingame items) source code. It will download to a directory where each class has a file with it. Upload will only send files that changed. It won't add or delete code if not already present, even if invalid.

## Requirements

```
pip3 install requests
```

## Commands

```
python3 auth.py --login=[login] --password=[password]
python3 download.py --auth=[token] --location=[workspace]
python3 diff.py --auth=[token] --location=[workspace]
python3 test.py --location=[workspace]
python3 upload.py --auth=[token] --location=[workspace]
```

## Typical workflow

```
export auth_token=$(python3 auth.py --login=[login] --password=[password])
python3 download.py --auth=$(auth_token)

# Work on files

python3 diff.py --auth=$(auth_token)
python3 test.py
python3 upload.py --auth=$(auth_token)
```

or just use './test-and-upload.sh', which will call test.py and upload.py.