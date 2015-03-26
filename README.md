# pg_qtop

Simple ruby program that shows you queries running using pg_stat_statements.

This is different from the pg_stat_activity view in that it shows you all the queries
that have run since the program was started, not just the queries running at the moment
when you're looking at it.

## Installation

```
gem install pg_qtop
```

## Usage

```
pg_qtop -d DATABASE -h HOSTNAME -p PORT -U USER
```

In order to filter queries on a certain table, specify it with `-t`:

```
pg_qtop -d DATABASE -t TABLE
```

You can also filter the kind of statements that are shown with `-s`, e.g.:

```
pg_qtop -d DATABASE -t TABLE -s insert
```

## Authors

- [Lukas Fittl](https://github.com/lfittl)

## License

pg_qtop is licensed under the 3-clause BSD license, see LICENSE file for details.
