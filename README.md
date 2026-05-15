# Stone Creek CodeSync

This tool is used to help manipulate class (ingame items) source code. It will download to a directory where each class has a file with it. Upload will only send files that changed. It won't add or delete code if not already present, even if invalid.

## Requirements

```
pip3 install requests
```

## Commands

Use the commands inside the 'tools' directory:

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

## New: autodetect filesystem changes

* Make sure the script 'initenv.sh' has the correct settings (login name and password).
* Use:
```
./monitor.sh
```

It will check for changes in the 'workspace' directory, and if any, will run test.py and - if tests pass - will upload to the server.

## Autodetect server modules

The script 'monitor-development.sh' will observer the './servers/development' directory and if any file changes, it will concatenate them and regenerate './servers/Development-User.lua'. The files _commons.lua and _utils.lua are garanteed to be first, in that order.

```
cd servers
./monitor-development.sh
```

### Notes and references

URL on production: 'https://stonecreek.pro'
URL on staging: 'http://192.168.50.70:8088'

https://github.com/IUdalov/u-test
