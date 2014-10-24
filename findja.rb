#!/usr/bin/ruby
# coding: cp932

require 'nkf'
require 'optparse'

def cmdline
  args = {}
  OptionParser.new do |parser|
    parser.on('-f', '--file', 'ファイル名を出力する。'){|v| args[:filename] = v}
    parser.on('-l', '--line', '行番号を出力する。'){|v| args[:lineno] = v}
    parser.on('-c', '--code', 'エンコード名を出力する。'){|v| args[:encode] = v}
    parser.on('-d VALUE', '--dir VALUE', 'トップディレクトリの指定。なければカレントディレクトリ以下。'){|v| args[:dir] = v}
    parser.on('-s [VALUE]', '--split [VALUE]', '区切り文字。(デフォルトはカンマ)'){|v| args[:split] = v}
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

Dir::glob("#{args[:dir]}/*.{c,h,rc,cpp,hpp}").each {|f|
  File::open(f) {|file|
    no = 1
    while line = file.gets
      # line.slice!(/\/\/.*$/)
      word = line.scan(/".*?"/)
      word.each {|w|
        code = NKF.guess(w)
        if code != NKF::ASCII then
          if args[:filename]
            print "#{f}"
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
          print w, "\n"
        end
      }
      no += 1
    end
  }
}
