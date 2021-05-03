# RakeZiphandler

Rakeによるzipの生成、受け渡し等の一連のタスクを定義する gem である。

* zipの生成
* zipの世代管理
* zipのアップロードとその世代管理
* zip生成前に行うタスクの指定

などの機能がある。

このクラスをnewすると指定されたネームスペース(デフォルトはzip)にmake, sweep, deployターゲットが定義される。つまり`rake zip:make`等のタスクが定義される。

* make: zipファイルを作る
* sweep: 古いzipファイルを消す。残すのは最新nremains個(デフォルト2)である
* deploy: remote_pathとzipdirの内容を同期する

同期にはrsyncを子プロセスで起動している。なのでrsyncが `PATH` 上に存在している必要がある。
このときrsyncにはオプションとして `-av --delete` を渡している。

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rake_ziphandler'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rake_ziphandler

## Usage

```ruby:Rakefile
ZipHandler.new(
  prefix:       # zipファイル名の先頭固定部分 (*)
  content:      # zipに入れる内容 (*)
  zipdir:       # zipを作成するディレクトリ (*)
  remote_path:  # 同期先のパス (rsync形式)  (*)
  zipopt:       # zip生成時につけるオプション (`-x .DS_Store -r`)
  nremains:     # 古いzipを残す数 (`2`)
  depend_on:    # makeが依存するタスクを指定 -- sweep_macbinary等を想定 (`[]`)
  after_deploy: # deploy後に実行するブロック。ブロックにはselfを渡す。(`->(_self){}`)
  namespace:    # タスクのネームスペース (`:zip`)
  echo:         # コマンドラインをエコーするとき (`true`)
)
```
`(*)`は必須のオプションである。そうでないものはカッコ内にデフォルト値を記してある。

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hage/rake_ziphandler.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
