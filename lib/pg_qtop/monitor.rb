require 'rubygems'
require 'mixlib/cli'
require 'pg'
require 'pg_query'
require 'curses'

module PgQtop
  class CLIHelper
    include Mixlib::CLI

    option :dbname,
        short: "-d DATABASE",
        long: "--database DATABASE",
        description: "database name to connect to",
        required: true

    option :host,
        short: "-h HOSTNAME",
        long: "--host HOSTNAME",
        description: "database server host"

    option :port,
        short: "-p PORT",
        long: "--port PORT",
        description: "database server port (default: 5432)"

    option :user,
        short: "-U USERNAME",
        long: "--username USERNAME",
        description: "database user name"

    option :table,
        short: "-t TABLE",
        long: "--table TABLE",
        description: "Only show queries that use the specified table"

    option :statement_type,
        short: "-s TYPE",
        long: "--statement-type TYPE",
        description: "Only show queries of the specified type (SELECT, INSERT, UPDATE or DELETE)"
  end

  module Monitor
    extend self

    def call
      cli = CLIHelper.new
      cli.parse_options

      Curses.noecho
      Curses.init_screen

      conn = PG::Connection.open cli.config.slice(:dbname, :host, :port, :user)
      conn.exec('SELECT pg_stat_statements_reset()')

      while true do
        Curses.setpos(0, 0)
        queries = conn.exec('SELECT query, calls, total_time, shared_blks_read, shared_blks_hit FROM pg_stat_statements').to_a

        queries = queries.sort_by {|q| (q["total_time"].to_f / q["calls"].to_f) }.reverse

        Curses.addstr("AVG\t| CALLS\t| HIT RATE\t| QUERY\n")
        Curses.addstr("-" * 80 + "\n")

        queries.each do |query|
          parsed_query = PgQuery.parse(query["query"])

          next if cli.config[:statement_type] && !matches_statement_type?(parsed_query, cli.config[:statement_type])
          next if cli.config[:table] && !parsed_query.tables.include?(cli.config[:table])

          hit_rate = 100.0 * query["shared_blks_hit"].to_f / (query["shared_blks_hit"].to_i + query["shared_blks_read"].to_i)

          Curses.addstr format("%0.1fms\t", query["total_time"].to_f / query["calls"].to_f)
          Curses.addstr format("| %d\t", query["calls"].to_i)

          if hit_rate.nan?
            Curses.addstr "| -\t\t"
          else
            Curses.addstr format("| %0.1f\t\t", hit_rate)
          end
          Curses.addstr format("| %s\n", query["query"].gsub(/\s+/, " ").strip)
        end

        Curses.refresh

        sleep 1
      end

      Curses.close_screen
    end

    def matches_statement_type?(parsed_query, filter)
      filter = filter.upcase
      filter = 'INSERT INTO' if filter == 'INSERT'
      filter = 'DELETE FROM' if filter == 'DELETE'
      parsed_query.parsetree.flat_map {|q| q.keys }.include?(filter)
    end
  end
end
