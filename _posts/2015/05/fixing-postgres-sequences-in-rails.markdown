---
categories:
- activerecord
- rails
- postgres
comments: false
date: 2015-05-07T18:46:09-05:00
description: "A simple fix when PostgreSQL gets confused about its sequences"
post: true
title: Fixing PostgreSQL Sequences in Rails
---

I've been helping a friend launch a site he purchased as a way of earning some
passive income. The site itself is really old and we've rewritten it from
scratch, including migrating it from MySQL to PostgreSQL.

As part of the migration process, I've occasionally needed to send a dump of my
database to him or to the staging server. In doing so, we're often met with the
following error:

```
PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "posts_pkey"
```

This error means that PostgreSQL tried to use a value that already exists for
the primary key of the new record. PostgreSQL keeps track of what the next
auto-incremented primary key value needs to be separately from the table, rather
than merely incrementing upon the current max value. Presumably this is to avoid
potential race conditions. When the sequence and the table's primary key get out
of sync, we end up with the error above.

When loading a database from another source, if sequences aren't included in the
dump, the sequences are likely to get out of sync from where they are supposed
to be. To resolve this issue, the [PostgreSQL Wiki](https://wiki.postgresql.org/wiki/Fixing_Sequences) has a solution:

``` sql
SELECT 'SELECT SETVAL(' ||
       quote_literal(quote_ident(PGT.schemaname) || '.' || quote_ident(S.relname)) ||
       ', COALESCE(MAX(' ||quote_ident(C.attname)|| '), 1) ) FROM ' ||
       quote_ident(PGT.schemaname)|| '.'||quote_ident(T.relname)|| ';'
FROM pg_class AS S,
     pg_depend AS D,
     pg_class AS T,
     pg_attribute AS C,
     pg_tables AS PGT
WHERE S.relkind = 'S'
    AND S.oid = D.objid
    AND D.refobjid = T.oid
    AND D.refobjid = C.attrelid
    AND D.refobjsubid = C.attnum
    AND T.relname = PGT.tablename
ORDER BY S.relname;
```

If you were to run this in the PostgreSQL client, you would see output like
this:

``` sql
                                                   query
------------------------------------------------------------------------------------------------------------
 SELECT SETVAL('public.authentications_id_seq', COALESCE(MAX(id), 1) ) FROM public.authentications;
 SELECT SETVAL('public.brands_id_seq', COALESCE(MAX(id), 1) ) FROM public.brands;
 SELECT SETVAL('public.comments_id_seq', COALESCE(MAX(id), 1) ) FROM public.comments;
 SELECT SETVAL('public.follows_id_seq', COALESCE(MAX(id), 1) ) FROM public.follows;
 SELECT SETVAL('public.pg_search_documents_id_seq', COALESCE(MAX(id), 1) ) FROM public.pg_search_documents;
 SELECT SETVAL('public.posts_id_seq', COALESCE(MAX(id), 1) ) FROM public.posts;
 SELECT SETVAL('public.series_id_seq', COALESCE(MAX(id), 1) ) FROM public.series;
 SELECT SETVAL('public.users_id_seq', COALESCE(MAX(id), 1) ) FROM public.users;
 SELECT SETVAL('public.votes_id_seq', COALESCE(MAX(id), 1) ) FROM public.votes;
(10 rows)

Time: 2.624 ms
```

Although we could cut and paste that output into the Postres client each time we
needed to resolve this issue, it makes more sense to automate things; and we can
do that with a simple rake task:

``` ruby
namespace :db do
  desc "reset sequences for a specific table or all tables"
  task :sequence_reset => :environment do
    sql = <<-SQL
SELECT 'SELECT SETVAL(' ||
       quote_literal(quote_ident(PGT.schemaname) || '.' || quote_ident(S.relname)) ||
       ', COALESCE(MAX(' ||quote_ident(C.attname)|| '), 1) ) FROM ' ||
       quote_ident(PGT.schemaname)|| '.'||quote_ident(T.relname)|| ';' as query
FROM pg_class AS S,
     pg_depend AS D,
     pg_class AS T,
     pg_attribute AS C,
     pg_tables AS PGT
WHERE S.relkind = 'S'
    AND S.oid = D.objid
    AND D.refobjid = T.oid
    AND D.refobjid = C.attrelid
    AND D.refobjsubid = C.attnum
    AND T.relname = PGT.tablename
ORDER BY S.relname;
    SQL

    ActiveRecord::Base.connection.execute(sql).each do |query|
      ActiveRecord::Base.connection.execute(query['query'])
    end
  end
end
```

You can see we're just assigning the original SQL we borrowed from the
PostgreSQL Wiki to a `sql` variable. From there we are executing that SQL, and
then executing each of the resulting SQL statements.

To execute this Rake task, run `rake db:sequence_reset`, and you're good to go.
