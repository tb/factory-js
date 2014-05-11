# Factory [![Build Status](https://travis-ci.org/tb/factory.svg)](https://travis-ci.org/tb/factory)

Building JavaScript objects inspired by [rosie](https://github.com/bkeepers/rosie) and
[factory_girl](https://github.com/thoughtbot/factory_girl).

# Usage

    Factory.define('post', function() {
      this.sequence('id');
      this.sequence('title', function(i) {
        return "Post " + i;
      });
      this.attr('content', null);
      return this.after(function() {
        if (!this.content) {
          return this.content = "" + this.title + " content";
        }
      });
    });

    Factory.define('category', function() {
      this.sequence('id');
      this.sequence('name', function(i) {
        return "Category " + i;
      });
      this.ignore('postsCount', 0);
      return this.after(function(attributes) {
        return this.posts = Factory.buildList('post', attributes.postsCount);
      });
    });

NOTE: looks better with CoffeeScript ;-)

## Build with no attributes

    Factory.build('post')
    # result: {"id":1,"title":"Post 1","content":"Post 1 content"}

## Build with attributes

    Factory.build('post', content: 'my content')
    # result: {"content":"my content","id":1,"title":"Post 1"}

## Build with ignored attribute and after() callback

    Factory.build('category', name: 'First category', postsCount: 2)

result:

    {
      "name":"First category",
      "id":1,
      "posts":[
        {"id":1,"title":"Post 1","content":"Post 1 content"},
        {"id":2,"title":"Post 2","content":"Post 2 content"}
      ]
    }

## Build with traits

TODO: add example

## Custom build function to plug into Ember.js

    class Factory.EmberDataAdapter extends Factory.Adapter
      build: (factory, name, attrs) ->
        Ember.run -> App.__container__.lookup('store:main').createRecord name, attrs

    Factory.adapter = new Factory.EmberDataAdapter()
 
See live example at [jsbin](http://emberjs.jsbin.com/serolule/edit)

NOTE: You need to call Factory.reset() to reset sequences for each test run.

# Contributing

    git clone git@github.com:tb/factory.git
    cd factory
    npm install
    grunt build
