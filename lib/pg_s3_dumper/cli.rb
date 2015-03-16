module PgS3Dumper
  module CLI
    module_function

    def start
      options = {}

      OptionParser.new do |opts|
        opts.banner = "Usage: pg_s3_dumper options"


        opts.separator "Commands options:"
        opts.on("-c", "--command=COMMAND", "Command to execute",
               " - list - List all backups",
               " - backup - Create a new backup",
               " - cleanup - Delete all backups") do |v|
          options[:command] = v.to_sym
        end

        opts.on("-p", "--[no-]prune", "Prune (delete) old backups.",
                                "When pruning is off all backups are kept.",
                                "When pruning is on, the following backups are kept:",
                                " - all backups for today",
                                " - 1 per day for the last week",
                                " - 1 per week for the last month",
                                " - 1 per month for the last year") do |v|
          options[:prune] = v
        end

        opts.separator ""
        opts.separator "Configuration options:"

        opts.on("-d", "--database URL", "Database to use, must be an URL in the form:",
                                        "'postgres://username:password@hostname:port/database',",
                                        "it will be passed directly to the pg_dump command.",
                                        "If not set, the environment variable DATABASE_URL is used.") do |v|
          options[:database_url] = v
        end

        opts.on("-k", "--aws-key KEY", "AWS key, must have read write access to the bucket.",
                                       "If not set, the environment variable AWS_ACCESS_KEY_ID is used.") do |v|
          options[:aws_key] = v
        end

        opts.on("-w", "--aws-secret SECRET", "AWS secret key.",
                                             "If not set, the environment variable AWS_SECRET_ACCESS_KEY is used.") do |v|
          options[:aws_secret] = v
        end

        opts.on("-r", "--aws-region REGION", "AWS region your bucket resides in.",
                                             "If not set, the environment variable AWS_REGION is used.") do |v|
          options[:aws_region] = v
        end

        opts.on("-u", "--aws-url URL", "AWS destination, must be an URL in the form:",
                                             "'s3://bucket/prefix'.",
                                             "If not set, the environment variable AWS_URL is used.") do |v|
          options[:aws_url] = v
        end

        opts.separator ""
        opts.separator "General options:"

        opts.on("-v", "--version", "Output version information, then exit.") do
          puts PgS3Dumper::VERSION
          exit
        end

        opts.on("-h", "--help", "Show this help, then exit.") do
          puts opts.help
          exit
        end


      end.parse!

      begin
        dumper = PgS3Dumper::Dumper.new(options)
        dumper.run(options[:command])
      rescue PgS3Dumper::Error => e
        puts "ERROR: #{e.message}."
      end

    end
  end
end

