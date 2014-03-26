# Factory

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

TODO: add example

# Contributing

    git clone git@github.com:tb/factory.git
    cd factory
    npm install
    grunt build
