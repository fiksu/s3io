# S3io

[![Build Status](https://travis-ci.org/fiksu/s3io.png)](https://travis-ci.org/fiksu/s3io)

An IO-compatible wrapper for S3.

Note: this repository was moved to https://github.com/arp/s3io to the maintainer's account.

Amazon's official AWS SDK (version 1) provides an API for S3 that isn't compatible with Ruby's standard IO class and its derivatives. This gem provides a thin wrapper around AWS SDK (version 1) that makes it possible to access objects stored on S3 as if they were instances of File or StringIO classes.

Both streamed reads and writes are supported.

## Warning

Reads guarantee consistency if S3 file changes while being streamed, but only if versioning has been enabled for that file. S3io always reads from the same version of the file it read the first chunk from. If a non-versioned file is changed during the read process, an ```S3io::ReadModifiedError``` is thrown. To protect against this, enable versioning for the bucket where file is located. Lifecycle policy can be used to automatically delete older versions based on their age.

## Installation

Add this line to your application's Gemfile:

    gem 's3io'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install s3io

## Usage

Once wrapped, S3 objects behave the way you'd expect from an ordinary IO object.
It can read:

    require 'aws-sdk'
    require 's3io'

    s3_object = S3.buckets['some-bucket'].objects['path/to/object']
    io = S3io.open(s3_object, 'r')

    first_100_bytes = io.read(100) # reading first 100 bytes

    io.rewind # back to the first byte

    io.lines do |line|
      puts line # Just printing lines one by one
    end

    io.pos = 42 # seek byte 42

    puts io.read # and print everything from that byte to the end


It can write:

    require 'aws-sdk'
    require 's3io'

    s3_object = S3.buckets['some-bucket'].objects['path/to/object']

    S3io.open(s3_object, 'w') do |s3io|
      io.write 'abc'
      io.write 'def'
    end

## To do

* Code documentation

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
