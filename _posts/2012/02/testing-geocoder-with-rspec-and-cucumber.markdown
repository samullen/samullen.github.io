---
title: "Testing Geocoder with RSpec and Cucumber"
description: "How to simply set up your test environment to handle the Geocoder
gem's calls to geocoding providers."
date: 2012-02-03
comments: true
post: true
categories: [tdd, cucumber, rspec, geocoding, geocoder, testing]
---
If you are using the [Geocoder gem](https://github.com/alexreisner/geocoder) then your tests related to geocoding are most likely hitting one of the gem's geolocation providers. That's probably not what you want: 1) your tests run slower; 2) you use up your request quota for your specified provider; 3) and most importantly, you are not able to control the data returned. A good solution to this is to use the [fakeweb gem](https://github.com/chrisk/fakeweb) - and it's really easy to set it up.

### The Steps
First, add `fakeweb` to your `Gemfile` under the `:test` group and then "bundle install".

``` ruby
group :test do
  ...
  gem 'fakeweb'
  ...
end
```

Now, put the following code in a file under `spec/support` (or `test/support`). I use `geocoding.rb`, but you can name it anything you wish.

``` ruby
google_json = <<-JSON
{
  "status": "OK",
  "results": [ {
    "types": [ "street_address" ],
    "formatted_address": "45 Main Street, Long Road, Neverland, England",
    "address_components": [ {
      "long_name": "45 Main Street, Long Road",
      "short_name": "45 Main Street, Long Road",
      "types": [ "route" ]
    }, {
      "long_name": "Neverland",
      "short_name": "Neverland",
      "types": [ "city", "political" ]
    }, {
      "long_name": "England",
      "short_name": "UK",
      "types": [ "country", "political" ]
    } ],
    "geometry": {
      "location": {
        "lat": 0.0,
        "lng": 0.0
      }
    }
  } ]
}
JSON

FakeWeb.register_uri(:any, %r|http://maps\.googleapis\.com/maps/api/geocode|, :body => google_json)
```

To reference the above file in Cucumber, add the following line to your `features/support/env.rb` file:

``` ruby
require Rails.root.join("spec/support/geocoding")
```

### The Explanation
Even though there is a lot of text in the `geocoding.rb` file, there really isn't much going on. In the "here document" (the parts between `google_json = <<-JSON` and `JSON`) a big blob of JSON data gets assigned to the `google_json` variable. That's it.

On the last line, we tell the FakeWeb gem that any call to Google's API needs to be captured and then return a blob of JSON data (what's stored in the `google_json` variable) "successfully". Note that the URL used above is a regular expression and is only a portion of the full address in order to capture everything sent to that location.

It is entirely likely that you are using an alternate provider to Google. If this is the case, you will need to retrieve the appropriate JSON data yourself. You can find this data in the [Geocoder test fixtures](https://github.com/alexreisner/geocoder/tree/master/test/fixtures). Look for the files beginning with your provider and ending with "madison_square_garden.json".

Alternate URLs for providers can be found in the [Geocoder "lookups" files](https://github.com/alexreisner/geocoder/tree/master/lib/geocoder/lookups). The URLs reside in the `query_url` method.

If you've done everything correctly, your test should now stay local to your machine and return only the data you've specified. From here, you can set up tests  for failures, alternate geolocation providers, specific latitude/longitude coordinates, and more. You now have all that is necessary to test geolocation calls.
