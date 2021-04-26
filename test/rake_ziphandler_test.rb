# frozen_string_literal: true

require_relative "../lib/rake_ziphandler"

module RakeZipHandlerTest
  def self.test(_argv)
    flag_called_task_foo = false
    Rake::Task.define_task(:default) # テスト時にデフォルトタスクがないとrakeがabortする
    Rake::Task.define_task(:foo) do
      flag_called_task_foo = true
    end

    testdir = File.join(__dir__, 'test/site')
    zipdir = File.join(__dir__, 'test/zip')
    prefix = 'foo'
    system("mkdir -p #{testdir} ; echo hello > #{testdir}/test.txt")
    FileUtils.mkdir_p(zipdir)

    _z = RakeZipHandler.new(prefix: prefix, content: testdir, zipdir: zipdir, remote_path: '', depend_on: [:foo], echo: false)

    # test sweep
    FileUtils.touch "#{zipdir}/#{prefix}-200101-1212.zip"
    FileUtils.touch "#{zipdir}/#{prefix}-200101-1213.zip"
    FileUtils.touch "#{zipdir}/#{prefix}-200101-1214.zip"
    Rake::Task['zip:sweep'].invoke
    ls = Dir[File.join(zipdir, '*')]

    raise "sweep後zipファイルの数は2個でなければならない" if ls.size != 2

    %w(1213.zip 1214.zip).each do |fn|
      raise "sweep #{fn} が消えている" unless ls.find {|f| f =~ /#{fn}$/}
    end

    Rake::Task['zip:make'].invoke
    raise "make前にタスクfooが実行されていなければならない" unless flag_called_task_foo
  ensure
    system("rm -rf #{File.join(__dir__, 'test')}")
  end
end

RakeZipHandlerTest.test(ARGV)

# Local Variables:
# compile-command: "rake -f rake_ziphandler_test.rb"
# End:
