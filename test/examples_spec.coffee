expect = require('chai').expect
Factory = require("#{if process.env.COVER then '../build/instrument/dist/' else '../dist/'}factory.js")

describe 'Examples', ->
  beforeEach ->
    Factory.clear()

  describe 'category with posts', ->
    beforeEach ->
      Factory.define 'post', ->
        @sequence 'id'
        @sequence 'title', (i) -> "Post #{i}"
        @attr 'content', null
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
      post = Factory.build 'post', content: 'my content'
      expect(post.content).to.equal 'my content'
      console.log JSON.stringify(post)

    it 'postsCount', ->
      category = Factory.build 'category', name: 'First category', postsCount: 2
      expect(category.name).to.equal 'First category'
      expect(category.posts).to.have.length 2
      console.log JSON.stringify(category)
