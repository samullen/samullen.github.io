---
title: "Validating Presence of Associations and Foreign Keys in Rails"
description: "A simple solution and explanation to the problem of ensuring either an association or foreign key is present."
date: 2013-12-31
post: true
categories: [ruby on rails, validations, ActiveRecord]
---

## The Problem

When working with ActiveRecord models, there are occasions where using either a
foreign key or an object to denote an association is desirable. It may be the
only available information about the foreign record is the key, or it may be
that only a "new" (i.e. not persisted) object has been created. To ensure the
association is present, you need to validate the presence of both the
association (i.e. the Object) and the foreign key.

Assuming we have a `User` model with a `has_many` association to a `Post` model,
the solution might look something like this:

``` ruby
class Post < ActiveRecord::Base
  belongs_to :user, :inverse_of => :posts
  
  validates :user, :presence => {:if => proc{|o| o.user_id.blank? }}
  validates :user_id, :presence => {:if => proc{|o| o.user.blank? }}
end
```

Here, we're validating the existence of the `User` association: first by
checking the presence of the object if the foreign key is blank; second by
checking the presence of the foreign key if the `User` association is blank.

This isn't a great solution, because it results in two error messages if the
validation fails.

## A New Validation

A better solution is to create a validator. To do that in Rails, the validator
file must be created under `lib/validators`, and the filename must be the [snake case](http://en.wikipedia.org/wiki/Snake_case) version of the class name (i.e.
ExistenceValidator => existence_validator.rb).

``` ruby
class ExistenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank? && record.send("#{attribute}_id".to_sym).blank?
      record.errors[attribute] << I18n.t("errors.messages.existence")
    end
  end
end
```

*lib/validators/existence_validator.rb*

As you can see, we subclass `ActiveModel::EachValidator` and override the
`validate_each` method.

Inside the method, we add to the `errors` list if either the value of what we
are testing is `#blank?` or if the foreign key is `#blank?` Just add the desired
error message to your `config/locales/en.yml` file (adjust for language).

``` yaml
en:
  errors:
    messages:
      existence: "must exist as an object or foreign key"
```
*config/locales/en.yml*

### Aside: #send

The above solution may be a little tricky if you're not too familiar with
[metaprogramming](http://en.wikipedia.org/wiki/Metaprogramming) in Ruby, so
we'll look at it a little more closely here.

``` ruby
record.send("#{attribute}_id".to_sym).blank?
```

In Ruby, the `#send` method takes a `symbol` as its first argument, and it
"sends" that symbol as a message to an object, (i.e. it calls a method of the
same name as the symbol).

We are defining the message to be sent with the `"#{attribute}_id".to_sym` bit –
in our use case, it will end up being `user_id`. That message gets sent to the
model instance the validation is defined within and determined if it is
`blank?`.

When fully translated, it looks like this: 

``` ruby
record.user_id.blank?
```

## Usage

Now that we've defined our new validation, let's use it. We can remove the two
`presence` validators we had before and replace them with the more succinct
`existence` validator.

``` ruby
class Post < ActiveRecord::Base
  belongs_to :user, :inverse_of => :posts
  
  validates :user, :existence => true
end
```

*Post model using new validator*

## Where It Doesn't Work

The solution is pretty good, but it assumes the foreign key is the same name as
the association, only with an appended `_id` (e.g. `user` and `user_id`).

For the occasion when you need to get around this, you'll want to create a sort
of "in class" validator for your odd association.

``` ruby
class Post < ActiveRecord::Base
  belongs_to :author, :class_name => User, :inverse_of => :posts

  validate :must_have_author

  private

  def must_have_author
    if author.blank? && user_id.blank?
      self.errors.add(:author, I18n.t("errors.messages.existence")) 
    end
  end
end
```

*Post model using specific validator*

At this point you should have a solution for 90% of what you're going to run
into with regard to validating associations. If you see something I missed, or
if there's a way I can improve anything above, please leave a comment and I'll
update the post accordingly.
