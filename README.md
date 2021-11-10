# PG S3 Dumper

This simple tool creates and expires postgresql backups on an S3 bucket.

In this document, "PG S3 Dumper" will be refered simply as "Dumper".

NOTE: This is alpha quality software, use at your own risks.

WARNING: Ensure you create a bucket and prefix specifically for this tool, with
proper IAM permissions to avoid dataloss in case of failure.

## Installation

Just install the gem.

    $ gem install pg_s3_dumper

## Usage

### Configuration

Dumper can be configured by command line arguments or environment variables.

For usage information:

    $ pg_s3_dumper -h

## TODO

- Make backup keep count configurable
- Write tests


## Contributing

1. Fork it ( https://github.com/kuon/pg_s3_dumper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
