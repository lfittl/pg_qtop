require 'rubygems'
require 'mixlib/cli'
require 'pg'
require 'pg_query'
require 'curses'

module PgQtop
  class CLIHelper
    include Mixlib::CLI

    option :database,
        short: "-d DATABASE",
        long: "--database DATABASE",
        description: "The database to be tracked",
        required: true

    option :table,
        short: "-t TABLE",
        long: "--table TABLE",
        description: "Only show queries that use the specified table"
  end

  module Monitor
    extend self

    def call
      cli = CLIHelper.new
      cli.parse_options

      Curses.noecho
      Curses.init_screen

      conn = PG::Connection.open(dbname: cli.config[:database])

      conn.exec('SELECT pg_stat_statements_reset()')

      while true do
        Curses.setpos(0, 0)
        queries = conn.exec('SELECT query, calls, total_time FROM pg_stat_statements').to_a

        queries = queries.sort_by {|q| (q["total_time"].to_f / q["calls"].to_f) }.reverse
        Curses.addstr("AVG\t| QUERY\n")
        Curses.addstr("-" * 80 + "\n")
        queries.each do |query|
          if cli.config[:table]
            next unless PgQuery.parse(query["query"]).tables.include?(cli.config[:table])
          end
          Curses.addstr("%0.1fms\t" % (query["total_time"].to_f / query["calls"].to_f))
          Curses.addstr("| " + query["query"].gsub(/\s+/, " ").strip + "\n")
        end
        Curses.refresh
        sleep 1
      end

      Curses.close_screen
    end
  end
end
