expect = require('chai').expect
Factory = require("#{if process.env.COVER then '../build/instrument/dist/' else '../dist/'}factory.js")

describe 'Factory', ->
  beforeEach ->
    Factory.clear()

  describe '#clear', ->
    it 'removes factories', ->
      Factory.define 'factoryItem'

      expect(Factory.factories).not.to.deep.equal {}
      Factory.clear()
      expect(Factory.factories).to.deep.equal {}

  describe '#reset', ->
    it 'resets sequences for factories', ->
      factory = Factory.define 'factoryItem', ->
        @sequence 'id'

      Factory.create 'factoryItem'

      expect(factory.sequences).to.deep.equal {id: 1}
      Factory.reset()
      expect(factory.sequences).to.deep.equal {}

  describe '#getFactory', ->
    it 'no error when factory defined', ->
      Factory.define 'factoryItem'

      expect((-> Factory.create 'factoryItem')).not.to.throw(Error)

    it 'error when factory not defined', ->
      expect((-> Factory.create 'xfactoryItem')).to.throw(Error)

  describe '#getTrait', ->
    beforeEach ->
      Factory.define 'factoryItem', ->
        @trait 'withTrait'

    it 'no error when factory defined', ->
      expect((-> Factory.create 'factoryItem withTrait')).not.to.throw(Error)

    it 'error when factory not defined', ->
      expect((-> Factory.create 'factoryItem xwithTrait')).to.throw(Error)

  describe '#create', ->
    it 'overwrite sequence', ->
      Factory.define 'factoryItem', ->
        @sequence 'id'

      expect(Factory.create 'factoryItem', id: 123).to.contain id: 123

    it 'overwrite attr', ->
      Factory.define 'factoryItem', ->
        @attr 'number', 123

      expect(Factory.create 'factoryItem', number: 567).to.contain number: 567

  describe '#createList', ->
    beforeEach ->
      Factory.define 'factoryItem', ->
        @sequence 'id'
        @attr 'number', 123

    it 'count', ->
      items = Factory.createList 'factoryItem', 2
      expect(items).to.have.length 2

    it 'default attr', ->
      items = Factory.createList 'factoryItem', 2
      expect(items[0]).to.deep.contain id: 1, number: 123
      expect(items[1]).to.deep.contain id: 2, number: 123

    it 'overwrite attr', ->
      items = Factory.createList 'factoryItem', 2, number: 567
      expect(items[0]).to.deep.contain id: 1, number: 567
      expect(items[1]).to.deep.contain id: 2, number: 567

  describe '#buildList', ->
    beforeEach ->
      Factory.define 'factoryItem', ->
        @sequence 'id'
        @attr 'number', 123

    it 'count', ->
      items = Factory.buildList 'factoryItem', 2
      expect(items).to.have.length 2

    it 'default attr', ->
      items = Factory.buildList 'factoryItem', 2
      expect(items[0]).to.deep.contain id: 1, number: 123
      expect(items[1]).to.deep.contain id: 2, number: 123

    it 'overwrite attr', ->
      items = Factory.buildList 'factoryItem', 2, number: 567
      expect(items[0]).to.deep.contain id: 1, number: 567
      expect(items[1]).to.deep.contain id: 2, number: 567

  describe '#buildWith', ->
    beforeEach ->
      Factory.buildWith (name, attrs) ->
        "#{name}: #{JSON.stringify attrs}"

      Factory.define 'factoryItem', ->
        @attr 'number', 123

    it 'customized', ->
      expect(Factory.build 'factoryItem').to.equal 'factoryItem: {"number":123}'

    it 'attributes not changed', ->
      expect(Factory.attributes 'factoryItem').to.deep.equal {"number":123}

  describe '#createWith', ->
    beforeEach ->
      Factory.createWith (name, attrs) ->
        "#{name}: #{JSON.stringify attrs}"

      Factory.define 'factoryItem', ->
        @attr 'number', 123

    it 'customized', ->
      expect(Factory.create 'factoryItem').to.equal 'factoryItem: {"number":123}'

    it 'attributes not changed', ->
      expect(Factory.attributes 'factoryItem').to.deep.equal {"number":123}
