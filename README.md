# do-spaces

This cookbook adds a do_space resource you can use to sync the content of
a DigitalOcean Space to your local filesystem or vice versa.

A basic example, which will sync the content of the directory '/web' in the
DigitalOcean Space 'my-space' to the local directory '/website'

```
do_space 'my-space' do
  local_path '/website'
  remote_path '/web'
  action :sync_local_dir
  key 'ABC123DEF456GHI789JK'
  secret_key 'abc123DEF456ghi789JKL012mno345PQR678stu901v'
  region 'nyc3'
end
```

Naturally, for security reasons, it would probably be a good idea to store the
key and secret_key somewhere securely rather than hardcoding them into your
recipes :)

## Supported OSs

Ubuntu 16.04

## Actions

Two actions are available:
* sync_local_dir (default): Syncs content from a DigitalOcean Space to a local directory.
* sync_remote_dir: Syncs content from a local directory to a DigitalOcean Space.

## Properties

#### Required:
* space: The name of the DigitalOcean Space. Can also be specified as the name of the resource for convenience.
* local_path: The local path to sync files from/to.
* key: A valid Spaces API key for the relevant DigitalOcean account.
* secret_key: The secret key that matches the above key.
* region: The DigitalOcean data center the Space is located in.

#### Optional:
* remote_path: The remote path on the Space to sync files from/to. Defaults to the root directory of the space.
* s3cfg_template: Specify a specific template to use for the s3cmd configuration instead of the one in this cookbook. Should generally not be necessary.

## What is this thing doing "under the hood"?

It's perfectly safe but a little janky. It basically just installs and uses s3cmd to manage your Space.
