--- 
title: MysqlDump with a Query Constraint
date: 2011-08-08
comments: false
post: true
categories: [mysql]
---
I made a minor mistake this morning and deleted more records than I should have; whoops. Rather than deleting records prior to July 1st which had not been completed, I deleted all records prior to July 1st; again, whoops. Of course I had a backup, but the question was, "How do I dump just the records I need?" Well, here's how: use the --query parameter with mysqldump. Here's what it looks like:

``` bash
mysqldump -u username -p database_name table_name --no-create-info --where="some_ids in (1,2,3,4,5) and completed_at is not null and start_at > '2011-07-01';" > ~/whoops.sql
```

You'll be prompted for you password, and you'll obviously want to change "username", "database_name", "table_name" and the "where" constraint to something germaine to your needs.

One last thing: take careful note of the "--no-create-info" parameter. If this - or some other, similar parameter - is not passed, the dump will contain "drop" and "create" commands for your table. This is likely the exact opposite of what you want.

At this point, it's just a matter of reloading the data:

``` bash
mysql -u username -p database_name table_name < /path/to/whoops.sql
```

That's it, you should be set.

If this post has been useful, I hope it's not because you wiped out some data like I did.
