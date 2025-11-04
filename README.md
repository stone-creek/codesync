# Stone Creek CodeSync

This tool is used to help manipulate class (ingame items) source code. It will download to a directory where each class has a file with it. Upload will only send files that changed. It won't add or delete code if not already present, even if invalid.

## Requirements

```
pip3 install requests
```

## Commands

```
python3 auth.py --url=[url] --login=[login] --password=[password]
python3 download.py --url=[url] --auth=[token] --location=[workspace]
python3 diff.py --url=[url] --auth=[token] --location=[workspace]
python3 test.py --url=[url] --location=[workspace]
python3 upload.py --url=[url] --auth=[token] --location=[workspace]
```

## Typical workflow

```
export auth_token=$(python3 auth.py --url=[url] --login=[login] --password=[password])
python3 download.py --url=[url] --auth=$(auth_token)

# Work on files

python3 diff.py --url=[url] --auth=$(auth_token)
python3 test.py
python3 upload.py --url=[url] --auth=$(auth_token)
```

or just use './test-and-upload.sh', which will call test.py and upload.py.

### Notes and references

URL on production: 'https://stonecreek.pro'
URL on staging: 'http://192.168.50.70:8088'

https://github.com/IUdalov/u-test