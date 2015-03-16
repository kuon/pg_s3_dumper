# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pg_s3_dumper/version'

Gem::Specification.new do |spec|
  spec.name          = "pg_s3_dumper"
  spec.version       = PgS3Dumper::VERSION
  spec.authors       = ["Nicolas Goy"]
  spec.email         = ["kuon@goyman.com"]


  spec.summary       = %q{Simple tool to dump postgresql database to an S3 bucket.}
  spec.homepage      = "http://github.com/kuon/pg_s3_dumper"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk", "~> 2.0"
  spec.add_dependency "activesupport", "~> 4.0"
  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
