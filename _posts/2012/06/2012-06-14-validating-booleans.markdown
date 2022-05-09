---
title: "Validating Booleans"
description: "A quick and simple way to add a validator for boolean fields."
date: 2012-06-14
comments: true
post: true
categories: [ruby on rails, validations]
---

I ran into an instance today wherein I needed to validate that a boolean field was either `true` or `false` and not `null`. I tried using `validates :fieldname, :presence => true`, but since `:presence` uses `#blank?` under the hood, it was reading `false` as not being present. (Why is `false` considered blank?)

Anyway, I needed a validator to test whether an attribute was either true or
false and I couldn't find anything among the standard validators, so I wrote my
own. 

Just plop this file in your app's `lib/validators` directory.

``` ruby
class TruthinessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value == true || value == false
      record.errors[attribute] << "must be true or false"
    end
  end
end
```

In your model, add the validation like so:

``` ruby
class SomeModel < ActiveRecord::Base
  ...

  validates :field_name, :truthiness => true

  ...
end
```

For more information on writing validators, see
[Getting Started with Custom Rails3 Validators](http://databasically.com/2010/11/08/gettings-started-with-custom-rails3-validators/).
