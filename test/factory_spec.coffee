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

  describe '#abstractBuildList', ->
    beforeEach ->
      Factory.define 'factoryItem', ->
        @sequence 'id'
        @attr 'number', 123
        @attr 'state', 'default'
        @trait 'active',   -> @attr 'state', 'active'
        @trait 'inactive', -> @attr 'state', 'inactive'

    describe '#buildList', ->
      it 'count', ->
        items = Factory.buildList 'factoryItem', 2
        expect(items).to.have.length 2

      it 'count and default attrs', ->
        items = Factory.buildList 'factoryItem', 2
        expect(items[0]).to.deep.contain id: 1, number: 123
        expect(items[1]).to.deep.contain id: 2, number: 123

      it 'count and overwrite attrs', ->
        items = Factory.buildList 'factoryItem', 2, number: 567
        expect(items[0]).to.deep.contain id: 1, number: 567
        expect(items[1]).to.deep.contain id: 2, number: 567

      it 'attrs list and overwrite attrs', ->
        items = Factory.buildList 'factoryItem', [{number: 123},{number: 567}], state: 'custom'
        expect(items[0]).to.deep.contain id: 1, number: 123, state: 'custom'
        expect(items[1]).to.deep.contain id: 2, number: 567, state: 'custom'

      it 'traits list and overwrite attrs', ->
        items = Factory.buildList 'factoryItem', ['active', 'inactive'], number: 567
        expect(items[0]).to.deep.contain id: 1, number: 567, state: 'active'
        expect(items[1]).to.deep.contain id: 2, number: 567, state: 'inactive'

    describe '#createList', ->
      it 'count', ->
        items = Factory.createList 'factoryItem', 2
        expect(items).to.have.length 2

      it 'count and default attrs', ->
        items = Factory.createList 'factoryItem', 2
        expect(items[0]).to.deep.contain id: 1, number: 123
        expect(items[1]).to.deep.contain id: 2, number: 123

      it 'count and overwrite attrs', ->
        items = Factory.createList 'factoryItem', 2, number: 567
        expect(items[0]).to.deep.contain id: 1, number: 567
        expect(items[1]).to.deep.contain id: 2, number: 567

      it 'attrs list and overwrite attrs', ->
        items = Factory.createList 'factoryItem', [{number: 123},{number: 567}], state: 'custom'
        expect(items[0]).to.deep.contain id: 1, number: 123, state: 'custom'
        expect(items[1]).to.deep.contain id: 2, number: 567, state: 'custom'

      it 'traits list and overwrite attrs', ->
        items = Factory.createList 'factoryItem', ['active', 'inactive'], number: 567
        expect(items[0]).to.deep.contain id: 1, number: 567, state: 'active'
        expect(items[1]).to.deep.contain id: 2, number: 567, state: 'inactive'

  describe '#buildAdapter', ->
    describe 'default', ->
      it 'Factory.Adapter', ->
        Factory.define 'factoryItem', -> @attr 'number', 123
        expect(Factory.factories['factoryItem'].buildAdapter).to.be.an.instanceof Factory.Adapter

    describe 'custom', ->
      beforeEach ->
        class Factory.JsonAdapter extends Factory.Adapter
          build: (name, attrs) -> "#{name}Build: #{JSON.stringify attrs}"
          create: (name, attrs) -> "#{name}Create: #{JSON.stringify attrs}"

        Factory.adapter = Factory.JsonAdapter

        Factory.define 'factoryItem', ->
          @attr 'number', 123

      it 'Factory.JsonAdapter', ->
        expect(Factory.factories['factoryItem'].buildAdapter).to.be.an.instanceof Factory.JsonAdapter

      it 'build changed', ->
        expect(Factory.build 'factoryItem').to.equal 'factoryItemBuild: {"number":123}'

      it 'create changed', ->
        expect(Factory.create 'factoryItem').to.equal 'factoryItemCreate: {"number":123}'

      it 'attributes not changed', ->
        expect(Factory.attributes 'factoryItem').to.deep.equal {"number":123}

  describe '#setupForEmber', ->
    MyApp = {}

    beforeEach ->
      Factory.setupForEmber MyApp
      Factory.define 'factoryItem', -> @attr 'number', 123

    it 'error when namespace not defined', ->
      expect((-> Factory.setupForEmber())).to.throw(Error)

    it '#adapter is Factory.EmberDataAdapter', ->
      expect(Factory.adapter).to.be.equal Factory.EmberDataAdapter
