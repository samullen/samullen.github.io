+++
title = "Naming Conventions for ActiveRecord Polymorphic Associations"
author = "Samuel Mullen"
date = "2016-09-06T21:21:08-05:00"
description = "Some guidelines for how to name ActiveRecord's polymorphic associations well."
tags = ["activerecord", "rails"]
+++

Ruby on Rails has a lot of great features to help build web applications quickly: migrations, view helpers, text manipulation methods, and more. One of the handier features – and one we're using extensively in a current project – is [polymorphic associations](http://guides.rubyonrails.org/association_basics.html#polymorphic-associations). 

Polymorphic associations allow a model to "belong to" multiple models through a single association. To make this happen, a model must have two new fields added noting the "ID" of the record and "type" of the class the record belongs to. The convention is to name the ID and type fields prefixed with an adjective ending in the "able" suffix. Some simple examples might include `postable_id` and `postable_type`, `commentable_id` and `commentable_type`, and `notable_id` and `notable_type`.

This works fine right up until you get into a situations where the naming you create doesn't quite make sense: duplicateable, ownerable, pledgeable, and authorable are example of some oddly named associations I've run across. While the "ownerable" and "authorable" association names look odd, you can still figure out that they refer to an "owner" and an "author". Problems arise, however, when a word can be either a noun or a verb as in the case of "duplicate" and "pledge". What do we do then?

Part of the problem is a result of treating conventions as something more than what they are. A convention is just "a way in which something is *usually* done", not a rule, so let's start by disregarding it when it doesn't make sense or when it doesn't help us reason about the problem.

Instead, let's look at the polymorphic relationship as a subject-object relationship and then use that to guide us in our naming. Is the table with the polymorphic fields being acted upon or is it the recipient of the action? If it is the recipient, it usually makes sense to use the "-able" suffix convention. If it is being acted upon, we can frequently use the "-or, -er" suffix.

To highlight what I mean, look at these examples of how we might name polymorphic associations when there are both direct *and* indirect objects.

**A comment was added to the post** - "post" is the indirect object (i.e. the recipient) so we can say that a "post" is "commentable". It can have comments added to it.

```
class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
end

class Post < ActiveRecord::Base
  has_many :comments, as: :commentable
end
```

**A note was added to a user** - here again we see that "user" is recipient of the action. Someone or some thing is adding a note (the object) to the user (the indirect object). We would use "notable" as our polymorphic association.

```
class Note < ActiveRecord::Base
  belongs_to :notable, polymorphic: true
end

class User < ActiveRecord::Base
  has_many :notes, as: :notable
end
```

This doesn't always work out perfectly. If we add products to an order via line
items, we wouldn't say the product is "line_itemable", but rather that the
product is "orderable".

```
class LineItem < ActiveRecord::Base
  belongs_to :orderable, polymorphic: true
end

class Product < ActiveRecord::Base
  has_many :line_items, as: :orderable
end
```

Contrast the above examples with when there are no indirect objects:

**A person wrote an article** - Here, we have a subject (person), object (article) relationship, so we'd say the person is the "author" of the article. You wouldn't want to say the person is an "articleable". That's just weird.

```
class Article < ActiveRecord::Base
  belongs_to :author, polymorphic: true
end

class Person < ActiveRecord::Base
  has_many :articles, as: :author
end
```

**An organization added a donation** - Again, the organization (subject) makes a donation (object). We'd say the organization is a "donor", not a "donationable".

```
class Donation < ActiveRecord::Base
  belongs_to :donor, polymorphic: true
end

class Organization < ActiveRecord::Base
  has_many :donations, as: :donor
end
```

Naming things is really hard, and any programmer who's been in the trenches will tell you that. When you get it right, thinking about the design and coding of the program just flows. When you get it wrong, an added level of effort is required to translate the logic from what it's named to what it means.

When dealing with ActiveRecord's polymorphic relationships, follow the conventions outlined above and it will take your closer toward naming things well. When they don't, ignore them; they're only conventions.
