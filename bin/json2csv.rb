require 'json'

# Class to convert a JSON file to a CSV file
class Json2csv
  attr_reader :data_path, :csv_path, :branches, :data
  def initialize
    @data_path = ARGV[0] || './data.json'
    @csv_path = ARGV[1] || './data_as_csv.csv'
    raise 'Data not found' unless File.exist?(data_path)
    @branches = []
  end

  def load_data
    # Json extraction
    json_file = File.read(data_path)
    @data = JSON.parse(json_file)
  end

  def generate_csv
    # Branches extraction
    find_branches(@data.first)

    puts "You've done the work once..(#{path})" if File.exist?(csv_path)

    # File management
    File.open(csv_path, 'w') do |file|
      # CSV generation
      lines = data.map { |json_user| extract_data(json_user).join(',') }
      write_on_file(file, lines)
    end
  end

  private

  def find_branches(data, branch: [])
    unless data.is_a?(Hash)
      store_branch(branch, data)
      return true
    end
    data.each do |key, value|
      store_branch(branch, key) && next unless value.is_a?(Hash)
      is_leaf = find_branches(value, branch: branch.push(key))
      branch.pop if is_leaf
    end
  end

  def store_branch(branch, key, joiner = '.')
    @branches.push((branch + [key]).join(joiner))
  end

  def extract_data(json_user)
    @branches.map do |br|
      value = self.class.extract_value(json_user, br.split('.'))
      self.class.serialize_to_csv(value)
    end
  end

  def write_on_file(file, lines, with_headers = true)
    # Write headers
    file.write(@branches.join(',') + "\n") if with_headers
    lines.each { |line| file.write(line + "\n") }
  end

  class << self
    def extract_value(hash_user, keys)
      new_hash = Hash[sanitize_hash(hash_user)]
      new_hash.dig(*keys.map(&:to_s))
    end

    def serialize_to_csv(val)
      val = '"' + val.join(',') + '"' if val.is_a?(Array)
      val
    end

    # Just in case you're trying to mess it up ;-)
    def sanitize_hash(hash)
      Hash[hash.collect { |k, v| [k.to_s, v.is_a?(Hash) ? sanitize_hash(v) : v] }]
    end
  end
end

# Not run during tests
if $PROGRAM_NAME == __FILE__
  ins = Json2csv.new
  ins.load_data
  ins.generate_csv
end
