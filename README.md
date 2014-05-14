# Factory [![Build Status](https://travis-ci.org/tb/factory.svg)](https://travis-ci.org/tb/factory)

Building JavaScript objects inspired by [rosie](https://github.com/bkeepers/rosie) and
[factory_girl](https://github.com/thoughtbot/factory_girl).

# Usage

    Factory.define('vote', function() {
      this.sequence('id');
      this.attr('value', 0);
      this.trait('up', function() {
        return this.attr('value', 1);
      });
      return this.trait('down', function() {
        return this.attr('value', -1);
      });
    });

    Factory.define('post', function() {
      this.sequence('id');
      this.sequence('title', function(i) {
        return "Post " + i;
      });
      this.attr('content', null);
      this.hasMany('votes', 'vote');
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

result:

    {
      "id":1,
      "title":"Post 1",
      "content":"Post 1 content"
    }

## Build with attributes

    Factory.build('post', content: 'my content')

result:

    {
      "id":1,
      "title":"Post 1",
      "content":"my content"
    }

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

## Build post with votes count

    Factory.build('post', {votes: 2})

result:

    {
      "content" : "Post 1 content",
      "id" : 1,
      "title" : "Post 1",
      "votes" : [
          {"id":1,"value":1},
          {"id":2,"value":1}
        ]
    }

## Build post with votes traits or attributes

    Factory.build('post', {votes: ['up', 'down', 'up']})

or

    Factory.build('post', votes: [{value: 1}, {value: -1}, {value: 1}])

result:

    {
      "content" : "Post 1 content",
      "id" : 1,
      "title" : "Post 1",
      "votes" : [
          {"id":1,"value":1},
          {"id":2,"value":-1},
          {"id":3,"value":1}
        ]
    }

## Setup for Ember.js

  Call `Factory.setupForEmber(App)` before factory definitions. See live example at [jsbin](http://emberjs.jsbin.com/serolule/edit)

NOTE: You need to call Factory.reset() to reset sequences for each test run.

# Contributing

    git clone git@github.com:tb/factory.git
    cd factory
    npm install
    grunt build
