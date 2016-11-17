# Factory [![Build Status](https://travis-ci.org/tb/factory.svg)](https://travis-ci.org/tb/factory)

Building JavaScript objects inspired by [rosie](https://github.com/bkeepers/rosie) and
[factory_girl](https://github.com/thoughtbot/factory_girl).

Factory can integrate with JavaScript framework persistence layer through [Adapters](#adapters).

## Usage

    Factory.define('vote')
      .sequence('id')
      .attr('value', 0)
      .trait('up', function() {
        return this.attr('value', 1);
      })
      .trait('down', function() {
        return this.attr('value', -1);
      });

    Factory.define('post')
      .sequence('id')
      .sequence('title', function(i) {
        return "Post " + i;
      })
      .attr('content', null)
      .hasMany('votes', 'vote')
      .after(function() {
        if (!this.content) {
          return this.content = "" + this.title + " content";
        }
      });

    Factory.define('category')
      .sequence('id')
      .sequence('name', function(i) {
        return "Category " + i;
      })
      .ignore('postsCount', 0)
      .after(function(attributes) {
        return this.posts = Factory.buildList('post', attributes.postsCount);
      });

### Build with no attributes

    Factory.build('post')

result:

    {
      "id":1,
      "title":"Post 1",
      "content":"Post 1 content"
    }

### Build with attributes

    Factory.build('post', {content: 'my content'})

result:

    {
      "id":1,
      "title":"Post 1",
      "content":"my content"
    }

### Build with ignored attribute and after() callback

    Factory.build('category',{name: 'First category', postsCount: 2})

result:

    {
      "name":"First category",
      "id":1,
      "posts":[
        {"id":1,"title":"Post 1","content":"Post 1 content"},
        {"id":2,"title":"Post 2","content":"Post 2 content"}
      ]
    }

### Build post with votes count

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

### Build post with votes traits or attributes

    Factory.build('post', {votes: ['up', 'down', 'up']})

or

    Factory.build('post', {votes: [{value: 1}, {value: -1}, {value: 1}]})

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

## Adapters

By default factory is building JavaScript objects using default `Factory.Adapter`

    class Factory.Adapter
      constructor: (factory) -> @factory = factory
      build: (name, attrs) -> attrs
      create: (name, attrs) -> attrs
      push: (name, object) -> @[name].push object

Factory integrates with Ember.js through `Factory.EmberDataAdapter` (used by `Factory.setupForEmber(App)`)

    class Factory.EmberDataAdapter extends Factory.Adapter
      build: (name, attrs) -> Ember.run => App.__container__.lookup('store:main').createRecord name, attrs
      create: (name, attrs) -> @build name, attrs
      push: (name, object) -> Ember.run => @get(name).addObject object

You can set adapter globally

    Factory.adapter = Factory.YourAdapter

or per factory definition

    Factory.define 'yourModel', ->
      @adapter Factory.YourAdapter

## Setup for Ember.js

Call `Factory.setupForEmber(App)` before factory definitions. See live example at [jsbin](http://emberjs.jsbin.com/serolule/edit)

NOTE: You need to call `Factory.reset()` to reset sequences for each test run.

## Contributing

    git clone git@github.com:tb/factory.git
    cd factory
    npm install
    grunt build
