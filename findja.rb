#!/usr/bin/ruby
# coding: cp932

=begin
"",''�ň͂܂ꂽ������ɑ΂��ē���B
\",\'�͏��O�B
�����s�ɕ����̕����񂪂����Ă��s�𕪂���STDOUT�ɏo�́B
=end

require 'nkf'
require 'optparse'

# ���`�p
delchars = ["[", "]", "'", "\"", "\\"]
# �����g���q
extentions = ["c", "h", "rc", "cpp", "hpp", "rb"]
def cmdline
  args = {}
  OptionParser.new do |parser|
    parser.on('-f', '--file', '�t�@�C�������o�͂���B'){|v| args[:filename] = v}
    parser.on('-l', '--line', '�s�ԍ����o�͂���B'){|v| args[:lineno] = v}
    parser.on('-c', '--code', '�G���R�[�h�����o�͂���B'){|v| args[:encode] = v}
    parser.on('-d VALUE', '--dir VALUE', '�g�b�v�f�B���N�g���̎w��B�Ȃ���΃J�����g�f�B���N�g���ȉ��B'){|v| args[:dir] = v}
    parser.on('-s [VALUE]', '--split [VALUE]', '��؂蕶���B(�f�t�H���g�̓J���})'){|v| args[:split] = v}
    # parser.on('-x [VALUE]', '--extentions [VALUE]', '�ǉ�����g���q�B(��������ꍇ��-x rb -x ext�Ƃ���)'){|v| args[:ext] = v}
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
