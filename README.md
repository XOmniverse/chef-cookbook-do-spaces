# do-spaces

Note: This cookbook has not been thoroughly tested! Use with caution! It should be considered an Alpha and not ready for production use.

This cookbook adds a do_space resource you can use to create and manipulate DigitalOcean spaces, and to sync the content of a DigitalOcean Space to your local filesystem or vice versa.

A basic example, which will create the Space 'my-space' if it doesn't exist, and sync the content of the local directory '/website' to the Space directory '/web'.

```
do_space 'my-space' do
  local_path '/website'
  remote_path '/web'
  action [:create, :sync_remote_dir]
  key 'ABC123DEF456GHI789JK'
  secret_key 'abc123DEF456ghi789JKL012mno345PQR678stu901v'
  region 'nyc3'
end
```

Naturally, for security reasons, it would probably be a good idea to store the
key and secret_key somewhere securely rather than hardcoding them into your
recipes :)

## Supported OSs

Ubuntu 14.04 and above

Debian 8 and above

Fedora 25 and above

CentOS 7
* Note: CentOS support requires installing some RPMs meant for Fedora 26. These will be installed automatically when using this recipe. This is because the version of s3cmd built into CentOS 7 doesn't seem to work correctly. Use with caution.

## Actions

* create: Creates a new private Space unless public_space is set to true, in which case, it creates a new public Space. If the Space already exists, updates the permissions of the Space based on the public_space property, while leaving permissions alone if public_space is set to its default value of nil.
* update: Updates the permissions of the Space based on the public_space property, but does nothing if public_space property is set to its default value of nil. Generates an error if the Space does not exist and the public_space property is set to true or false.
* delete: Deletes an existing Space. Continues without error if the Space doesn't exist.
* empty: Deletes all contents of a Space but does not delete the Space itself, leaving it empty. Generates an error if the Space does not exist.
* sync_local_dir: Syncs content from a Space to a local directory. If delete_removed is set to true, any files present locally but not in the Space will be deleted from the local file system. Generates an error if the Space does not exist; issuing a create action before this action will ensure that this does not occur.
* sync_remote_dir: Syncs content from a local directory to a Space. If delete_removed is set to true, any files present in the Space but not in the local directory will be deleted from the Space. Generates an error if the Space does not exist; issuing a create action before this action will ensure that this does not occur.

## Properties

#### Required:
* space: The name of the Space. Can also be specified as the name of the resource for convenience.
* key: A valid Spaces API key for the relevant DigitalOcean account.
* secret_key: The secret key that matches the above key.

#### Optional:
* region: The DigitalOcean data center the Space is located in. Defaults to nyc3.
* local_path: The local path to sync files from/to. Defaults to /do_space.
* remote_path: The remote path on the Space to sync files from/to. Defaults to the root directory of the space.
* delete_removed: Whether or not to remove files at the destination that no longer exist at the source. Defaults to false.
* public_space: Whether or not to make a Space public when using the create or update action. Defaults to nil but can be set to true, false, or nil.

## What is this thing doing "under the hood"?

It's perfectly safe but a little janky. It basically just installs and uses s3cmd to manage your Space.
