#!/usr/bin/ruby
# coding: cp932

=begin
"",''で囲まれた文字列に対して動作。
\",\'は除外。
同じ行に複数の文字列があっても行を分けてSTDOUTに出力。
=end

require 'nkf'
require 'optparse'

# 整形用
delchars = ["[", "]", "'", "\"", "\\"]
# 初期拡張子
extentions = ["c", "h", "rc", "cpp", "hpp", "rb"]
def cmdline
  args = {}
  OptionParser.new do |parser|
    parser.on('-f', '--file', 'ファイル名を出力する。'){|v| args[:filename] = v}
    parser.on('-l', '--line', '行番号を出力する。'){|v| args[:lineno] = v}
    parser.on('-c', '--code', 'エンコード名を出力する。'){|v| args[:encode] = v}
    parser.on('-d VALUE', '--dir VALUE', 'トップディレクトリの指定。なければカレントディレクトリ以下。'){|v| args[:dir] = v}
    parser.on('-s [VALUE]', '--split [VALUE]', '区切り文字。(デフォルトはカンマ)'){|v| args[:split] = v}
    # parser.on('-x [VALUE]', '--extentions [VALUE]', '追加する拡張子。(複数ある場合は-x rb -x extとする)'){|v| args[:ext] = v}
    parser.parse!(ARGV)
  end 
  args
end

args = cmdline
if !args[:split] then args[:split] = ","; end
if !args[:dir] then
  args[:dir] = "**"
else
  args[:dir] = args[:dir].gsub(/\\/, "/")
  args[:dir].slice!(/\/$/)
end

ext = "{"
extentions.each do |e|
  ext += e + ","
end
ext += "}"

Dir::glob("#{args[:dir]}/*.#{ext}").each do |path|
  File::open(path) do |file|
    no = 1
    while line = file.gets
      line.slice!(/(\\"|\\')/)
      word = line.scan(/(".*?"|'.*?')/)
      word.each do |s|
        str = s.to_s
        delchars.each {|del| str.delete!(del)}
        code = NKF.guess(str)
        if code != NKF::ASCII then
          if args[:filename]
            print "#{path}"
            print args[:split]
          end
          if args[:lineno]
            print no
            print args[:split]
          end
          if args[:encode]
            print code.name
            print args[:split]
          end
          print '"', str, '"', "\n"
        end
      end
      no += 1
    end
  end
end
