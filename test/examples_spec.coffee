expect = require('chai').expect
Factory = require("#{if process.env.COVER then '../build/instrument/dist/' else '../dist/'}factory.js")

describe 'Examples', ->
  beforeEach ->
    Factory.clear()

  describe 'category with posts and votes', ->
    beforeEach ->
      Factory.define 'vote', ->
        @sequence 'id'
        @attr 'value', 1
        @trait 'up', -> @attr 'value', 1
        @trait 'down', -> @attr 'value', -1

      Factory.define 'post', ->
        @sequence 'id'
        @sequence 'title', (i) -> "Post #{i}"
        @attr 'content', null
        @hasMany 'votes', 'vote'
        @after ->
          @content = "#{@title} content" unless @content

      Factory.define 'category', ->
        @sequence 'id'
        @sequence 'name', (i) -> "Category #{i}"
        @ignore 'postsCount', 0
        @after (attributes) ->
          @posts = Factory.buildList 'post', attributes.postsCount

    it 'content', ->
      post = Factory.build 'post'
      expect(post.content).to.equal 'Post 1 content'
      console.log JSON.stringify(post)

    it 'custom content', ->
      post = Factory.build('post', {content: 'my content'})
      expect(post.content).to.equal 'my content'
      console.log JSON.stringify(post)

    it 'postsCount', ->
      category = Factory.build('category',{name: 'First category', postsCount: 2})
      expect(category.name).to.equal 'First category'
      expect(category.posts).to.have.length 2
      console.log JSON.stringify(category)

    it 'hasMany votes count', ->
      post = Factory.build('post', {votes: 2})
      expect(post.votes).to.have.length 2
      console.log JSON.stringify(post)

    it 'hasMany votes traits', ->
      post = Factory.build('post', {votes: ['up', 'down', 'up']})
      expect(post.votes).to.have.length 3
      console.log JSON.stringify(post)

    it 'hasMany votes attributes', ->
      post = Factory.build('post', {votes: [{value: 1}, {value: -1}, {value: 1}]})
      expect(post.votes).to.have.length 3
      console.log JSON.stringify(post)
