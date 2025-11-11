# Сканер дублікатів у файловій системі

# Пройтися рекурсивно по каталогу, згрупувати потенційні 
# дублікати й підтвердити їх побайтною перевіркою. Звіт з 
# групами дублікатів зробити в duplicates.json або duplicates.csv
# як приклад
# {
#   "scanned_files": 15234,
#   "groups": [
#     {
#       "size_bytes": 1048576,
#       "saved_if_dedup_bytes": 2097152,
#       "files": [
#         "/data/photos/a.jpg",
#         "/data/backup/photos/a (copy).jpg",
#         "/data/dup/a_copy2.jpg"
#       ]
#     }
#   ]
# }
# ----------------------------------------------------------------------------------------------------------------------------------------

require "find"
require "digest"
require "json"

abort "U forgor the arg" if ARGV.empty?
ROOT  = ARGV[0]
CHUNK = 1024 * 1024

def sha256(path)
  d = Digest::SHA256.new
  File.open(path, "rb") do |f|
    while (buf = f.read(CHUNK))
      d.update(buf)
    end
  end
  d.hexdigest
end

def byte_equal?(a, b)
  File.open(a, "rb") do |fa|
    File.open(b, "rb") do |fb|
      loop do
        ba = fa.read(CHUNK)
        bb = fb.read(CHUNK)
        return true  if ba.nil? && bb.nil?
        return false if ba != bb
      end
    end
  end
end

files = []
Find.find(ROOT) do |p|
  begin
    files << { path: p, size: File.size(p), hash: sha256(p) }
  rescue => e
    warn "[skip] #{p}: #{e.message}"
  end
end

by_hash = files.group_by { |f| [f[:size], f[:hash]] }

groups = by_hash.values.filter_map do |arr|
  next if arr.size < 2
  anchor = arr.first[:path]
  size   = arr.first[:size]

  paths = []
  arr.each { |h| paths << h[:path] }

  confirmed = []
  paths.each do |p|
    if p == anchor || byte_equal?(anchor, p)
      confirmed << p
    end
  end

  next if confirmed.size < 2
  confirmed.sort!

  {
    size_bytes: size,
    saved_if_dedup_bytes: size * (confirmed.size - 1),
    files: confirmed
  }
end

report = { scanned_files: files.size, groups: groups }
File.write("duplicates.json", JSON.pretty_generate(report))

puts "Scanned: #{files.size} files"
puts "Groups:  #{groups.size}"
groups.each_with_index do |g, i|
  puts "Group ##{i+1} (#{g[:files].size} copies, size #{g[:size_bytes]} bytes):"
  g[:files].each { |p| puts "  #{p}" }
end
puts "Wrote:   duplicates.json"


# ruby .\PR3\PR3.rb "E:\testFolder"