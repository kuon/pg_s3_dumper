require "aws-sdk"

module PgS3Dumper
  class Error < ::StandardError
  end

  class Dumper

    attr_reader          :database_url,
                         :database_name,
                         :prefix,
                         :bucket

    def prune?
      @prune
    end

    def initialize(options)
      @database_url = options[:database_url] || ENV['DATABASE_URL']
      aws_region = options[:aws_region] || ENV['AWS_REGION']
      aws_key = options[:aws_key] || ENV['AWS_ACCESS_KEY_ID']
      aws_secret = options[:aws_secret] || ENV['AWS_SECRET_ACCESS_KEY']
      aws_url = options[:aws_url] || ENV['AWS_URL']
      @prune = options.has_key?(:prune) ? options[:prune] : false

      v = `pg_dump --version`
      v =~ /pg_dump \(PostgreSQL\) 9\.\d\.\d/ or raise Error, "pg_dump version 9.x.x is required and must be in the PATH"
      database_url or raise Error, "Database URL required."
      aws_url =~ %r{^s3://([^/]+)/(\S*?)/?$} or raise Error, "Invalid AWS URL"

      bucket_name = $1
      @prefix = "#{$2}/"

      database_url =~ %r{postgres://[^/]*/(.+)\??.*$} or raise Error, "Invalid database URL"
      @database_name = $1
      @prefix = File.join(prefix, database_name)

      aws_key && aws_secret or raise Error, "AWS key and secret required"

      cred = Aws::Credentials.new(aws_key, aws_secret)
      client = Aws::S3::Client.new(:credentials => cred, :region => aws_region)
      s3 = Aws::S3::Resource.new(:client => client)
      @bucket = s3.bucket(bucket_name)
    end

    def run(command)
      case command
      when :list
        list
      when :backup
        backup
      when :cleanup
        cleanup
      else
        raise Error, "Invalid command '#{command}'"
      end
    end

    def list
      f = "% 12s% 30s"
      puts f % ['id', 'date']
      puts "-" * 42
      find_backups.each do |b|
        puts f % [b.short_id, b.ts]
      end
    end

    def cleanup
      find_backups.each do |b|
        b.delete
      end
    end

    def backup
      backups = find_backups

      # Keep daily backups for one week
      # Keep weekly backups for one month
      # Keep monthly backups for one year
      days =
      7.times.map{|i| i.days.ago} +
      4.times.map{|i| i.weeks.ago} +
      12.times.map{|i| i.months.ago}

      days.each do |ts|
        backups.each do |b|
          b.keep_on_day(ts)
          # We kept one backup on day ts, go to next day
          break if b.keep
        end
      end

      # Keep all backups for today
      backups.each do |b|
        b.keep_on_day(Date.today)
      end

      # Make new backup
      key = "#{now.iso8601}-#{database_name.split('/').last}.dmp"
      file = Tempfile.new(key)

      puts "## Creating backup"

      system "pg_dump -Fc #{database_url} > #{file.path}" or fail 'Cannot create dump'

      obj = bucket.object(File.join(prefix, key))

      obj.upload_file(file.path, :metadata => {:backup_id => Backup.generate_id})
      file.close
      file.unlink
      bck = Backup.new(obj)
      puts "Created backup: #{bck}"

      if prune?
        puts "## Pruning old backups"
        backups.each do |b|
          b.prune
        end
      end
    end

    def now
      Time.now.utc
    end

    private
    def find_backups
      backups = []

      # Collect existing backups
      bucket.objects(:prefix => prefix).each do |o|
        backups << Backup.new(o.object)
      end

      backups.sort
    end

  end
end

