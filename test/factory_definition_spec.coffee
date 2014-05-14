expect = require('chai').expect
Factory = require("#{if process.env.COVER then '../build/instrument/dist/' else '../dist/'}factory.js")

describe 'FactoryDefinition', ->
  beforeEach ->
    Factory.clear()

  describe '#after', ->
    beforeEach ->
      Factory.define 'factoryItem', ->
        @sequence 'id'
        @after ->
          @factoryId = "Factory #{@id}"
        @trait 'withTrait', ->
          @after ->
            @traitId = "Trait #{@id}"

    it 'factory', ->
      json = Factory.create 'factoryItem'

      expect(json).to.contain factoryId: 'Factory 1'
      expect(json).to.not.contain traitId: 'Trait 1'

    it 'factory and trait', ->
      json = Factory.create 'factoryItem withTrait'

      expect(json).to.contain factoryId: 'Factory 1'
      expect(json).to.contain traitId: 'Trait 1'

  describe '#attr', ->
    it 'value', ->
      Factory.define 'factoryItem', ->
        @attr 'number', 123

      expect(Factory.create 'factoryItem').to.contain number: 123

    it 'value function', ->
      Factory.define 'factoryItem', ->
        @attr 'number', -> Math.floor (Math.random()*9)+1

      expect(Factory.create('factoryItem').number).to.be.within(1,10)

    it 'builds subitems', ->
      Factory.define 'factory_subitem', ->
        @sequence 'id'

      Factory.define 'factoryItem', ->
        @sequence 'id'
        @attr 'subitems', -> [
          Factory.create('factory_subitem'),
          Factory.create('factory_subitem')
        ]

      json = Factory.create 'factoryItem'

      expect(json).to.have.deep.property 'id', 1
      expect(json).to.have.deep.property 'subitems[0].id', 1
      expect(json).to.have.deep.property 'subitems[1].id', 2

  describe '#ignore', ->
    afterAttributes = null
    result = null

    beforeEach ->
      Factory.define 'factoryItem', ->
        @attr 'number', 123
        @ignore 'favorite', false
        @after (attributes) ->
          result = @
          afterAttributes = attributes

    it 'default ignored', ->
      Factory.create 'factoryItem'

      expect(result).not.to.contain favorite: false

    it 'overwrite ignored', ->
      Factory.create 'factoryItem', favorite: true

      expect(result).not.to.contain favorite: true

    it 'default', ->
      Factory.create 'factoryItem'

      expect(afterAttributes).to.deep.contain favorite: false

    it 'overwrite', ->
      Factory.create 'factoryItem', favorite: true

      expect(afterAttributes).to.deep.contain favorite: true

  describe '#sequence', ->
    it 'increments', ->
      Factory.define 'factoryItem', ->
        @sequence 'id'

      expect(Factory.create 'factoryItem').to.contain id: 1

    it 'increments with function', ->
      Factory.define 'factoryItem', ->
        @sequence 'fid', (i) -> "f#{i}"

      expect(Factory.create 'factoryItem').to.contain fid: 'f1'

  describe '#trait', ->
    beforeEach ->
      Factory.define 'factoryItem', ->
        @sequence 'id'
        @attr 'name', 'Name'

        @trait 'with_city', ->
          @attr 'city', 'City'

        @trait 'with_street', ->
          @attr 'street', 'Steet'

    it 'without traits', ->
      json = Factory.create 'factoryItem'

      expect(json).to.contain name: 'Name'
      expect(json).to.not.contain street: 'City'
      expect(json).to.not.contain street: 'Steet'

    it 'increment base ids', ->
      expect(Factory.create 'factoryItem').to.contain id: 1
      expect(Factory.create 'factoryItem with_city with_street').to.contain id: 2
      expect(Factory.create 'factoryItem').to.contain id: 3

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

        Factory.define 'factoryItem', ->
          @attr 'number', 123
          @adapter Factory.JsonAdapter

      it 'Factory.JsonAdapter', ->
        expect(Factory.factories['factoryItem'].buildAdapter).to.be.an.instanceof Factory.JsonAdapter

      it 'build changed', ->
        expect(Factory.build 'factoryItem').to.equal 'factoryItemBuild: {"number":123}'

      it 'create changed', ->
        expect(Factory.create 'factoryItem').to.equal 'factoryItemCreate: {"number":123}'

      it 'attributes not changed', ->
        expect(Factory.attributes 'factoryItem').to.deep.equal {"number":123}
