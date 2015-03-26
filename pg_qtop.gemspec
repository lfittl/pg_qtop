$:.push File.expand_path("../lib", __FILE__)
require 'pg_qtop/version'

Gem::Specification.new do |s|
  s.name        = 'pg_qtop'
  s.version     = PgQtop::VERSION

  s.summary     = 'PostgreSQL query monitor'
  s.description = 'Shows the top queries running on your server using pg_stat_statements'
  s.author      = 'Lukas Fittl'
  s.email       = 'lukas@fittl.com'
  s.license     = 'BSD-3-Clause'
  s.homepage    = 'http://github.com/lfittl/pg_qtop'

  s.executables = %w[
    pg_qtop
  ]

  s.files = %w[
    Rakefile
    bin/pg_qtop
    lib/pg_qtop.rb
    lib/pg_qtop/monitor.rb
    lib/pg_qtop/version.rb
  ]

  s.add_development_dependency 'rspec', '~> 2.0'

  s.add_runtime_dependency 'pg'
  s.add_runtime_dependency 'pg_query'
  s.add_runtime_dependency 'curses'
  s.add_runtime_dependency 'mixlib-cli'
  s.add_runtime_dependency 'activesupport'
end
