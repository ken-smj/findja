#!/usr/bin/ruby
# coding: cp932

require 'nkf'

# CODES = {
#   NKF::JIS      => "J",
#   NKF::EUC      => "E",
#   NKF::SJIS     => "S",
#   NKF::UTF8     => "U",
#   NKF::BINARY   => "B",
#   NKF::ASCII    => "A",
#   NKF::UNKNOWN  => "?",
# }

Dir::glob("**/*.{c,h,rc,cpp,hpp}").each {|f|
  # ここにマッチしたファイルに対して行う処理を記述する
  # この例ではファイル名とファイルのサイズを標準出力へ出力している
  puts "#{f}: #{File::stat(f).size} bytes"
  File::open(f) {|file|
    no = 1
    while line = file.gets
      line.slice!(/\/\/.*$/)
      code = NKF.guess(line)
      if code != NKF::ASCII
        # print no, ":", CODES.fetch(code), ":", line
        print no, ":", code.name, ":", line
      end
      no += 1
    end
  }
}
