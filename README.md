# Stratocumulus
[![Build Status](https://travis-ci.org/reevoo/stratocumulus.svg?branch=master)](https://travis-ci.org/reevoo/stratocumulus)
[![Coverage Status](https://coveralls.io/repos/reevoo/stratocumulus/badge.png)](https://coveralls.io/r/reevoo/stratocumulus)
[![Code Climate](https://codeclimate.com/github/reevoo/stratocumulus.png)](https://codeclimate.com/github/reevoo/stratocumulus)
[![Gem Version](https://badge.fury.io/rb/stratocumulus.svg)](http://badge.fury.io/rb/stratocumulus)


Stratocumulus is for backing up databases to cloud storage

## Installation

    $ gem install stratocumulus

## Usage

    $ stratocumulus backup /path/to/config.yml
    
```YAML
s3:
  access_key_id: KEY_ID
  secret_access_key: SECRET_KEY
  bucket: database-backups
  region: eu-west-1 # defaults to us-east-1
databases:
  -
    type: mysql
    name: database_name
    storage: s3
    username: database_user # defaults to root
    password: database_pass # defaults to no password
    host: db1.example.com # defaults to localhost
    port: 3306 # defaults to 3306
  -
    type: mysql
    name: some_other_database
    storage: s3
```
## Dependencies

* mysqldump
* gzip
* Ruby, (tested on mri 1.9.3, 2.0.0 and 2.1.2)

## Contributing

1. Fork it ( http://github.com/reevoo/stratocumulus/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
