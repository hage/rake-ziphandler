# frozen_string_literal: true

require_relative "rake_ziphandler/version"

class RakeZipHandler
  #  prefix: zipファイル名の先頭固定部分
  #  content: zipに入れる内容
  #  zipdir: zipを作成するディレクトリ
  #  remote_path: 同期先のパス (rsync形式)
  #  zipopt: zip生成時につけるオプション (`-x .DS_Store -r`)
  #  nremains: 古いzipを残す数 (`2`)
  #  depend_on: makeが依存するタスクを指定 -- sweep_macbinary等を想定 (`[]`)
  #  after_deploy: deploy後に実行するコード。selfを渡す。
  def initialize(prefix:,
                 content:,
                 zipdir:,
                 remote_path:,
                 namespace: :zip,
                 zipopt: '-x .DS_Store -r',
                 nremains: 2,
                 depend_on: [],
                 after_deploy: ->(_self) {})
    @prefix = prefix
    @content = content
    @zipdir = zipdir
    @remote_path = remote_path
    @namespace = namespace.intern
    @zipopt = zipopt
    @nremains = nremains
    @depend_on = depend_on
    @after_deploy = after_deploy

    @zipname = Time.now.strftime("#{@prefix}-%y%m%d-%H%M.zip")
    @zippath = File.join(@zipdir, @zipname)

    define_task
  end
  attr_reader :zipname

  def list
    Dir[File.join(@zipdir, "#{@prefix}-*.zip")].sort
  end

  def primary_zipname
    File.basename(list.last)
  end

  private

  def define_task
    extend Rake::DSL

    namespace @namespace do
      directory @zipdir

      desc "create a zip file"
      task make: [*@depend_on, @zipdir] do
        srcdir = File.dirname(@content)
        impdir = File.basename(@content)
        Dir.chdir(srcdir) do
          cmd = "zip #{@zipopt} #{@zippath} #{impdir}"
          sh cmd
        end
      end

      desc "sweep old zip files"
      task sweep: [@zipdir] do
        zipfiles = list
        zipfiles.pop(@nremains)
        File.delete(*zipfiles)
      end

      desc "sync zip files with remote directory"
      task deploy: [] do
        sh "rm -f #{@zipdir}/.DS_Store"
        sh "rsync -av --delete #{@zipdir}/ #{@remote_path}"
        @after_deploy.call(self)
      end

      desc "zip deploy suite -- sweep -> make -> deploy"
      task deploy_suite: ["#{@namespace}:sweep", "#{@namespace}:make", "#{@namespace}:deploy"]
    end
  end
end
