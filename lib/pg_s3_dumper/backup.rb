class Backup

  def self.generate_id
    SecureRandom.hex(32)
  end

  include Comparable

  attr_reader :s3_object, :ts, :keep

  def <=>(other)
    ts <=> other.ts
  end

  def initialize(s3_object)
    @s3_object = s3_object
    @ts = Time.parse(s3_object.key.split('/').last)
    @keep = false
  end

  def to_s
    "id: #{short_id}, key: #{basename}"
  end

  def on_day?(date)
    ts.strftime('%F') == date.strftime('%F')
  end

  def keep_on_day(date)
    @keep = true if on_day?(date)
  end

  def prune
    if keep
      puts "Keeping backup: #{self}"
    else
      delete
    end
  end

  def delete
    puts "Deleting backup: #{self}"
    s3_object.delete
  end

  def id
    @id ||= s3_object.metadata['backup_id']
  end

  def short_id
    id[0..8]
  end

  def basename
    File.basename(s3_object.key)
  end

end

