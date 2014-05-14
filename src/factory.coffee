class Factory
  @Adapter = class Adapter
    constructor: (factory) -> @factory = factory
    build: (name, attrs) -> attrs
    create: (name, attrs) -> attrs
    push: (name, object) -> @[name].push object

  @factories: {}
  @adapter = Factory.Adapter

  @clear: ->
    @factories = {}
    @adapter = Factory.Adapter

  @reset: ->
    for name,factory of @factories
      factory.sequences = {}

  @define: (name, block) ->
    definition = new FactoryDefinition(name)
    block.call(definition) if typeof block is 'function'
    @factories[name] = definition

  @getFactory: (name) ->
    factory = @factories[name]
    factory ? factory : throw new Error("undefined factory \"#{name}\"")

  @getTrait: (factory, name) ->
    trait = factory.traits[name]
    trait ? trait : throw new Error("undefined trait \"#{name}\" for factory \"#{@name}\"")

  @abstractBuild: (buildType, names, attrs) ->
    names = names.split /\s+/
    name = names[0]

    factory = @getFactory(name)
    traits = names[1..names.length].map (name) => @getTrait factory, name
    attributes = factory.attributes(attrs, traits)
    result = factory.build(buildType, name, attributes.withoutIgnored)
    traits.unshift(factory)
    traits.map (factory) -> factory.applyCallbacks result, attributes.withIgnored

    result

  @attributes: (names, attrs) -> @abstractBuild 'attributes', names, attrs
  @build:      (names, attrs) -> @abstractBuild 'build', names, attrs
  @create:     (names, attrs) -> @abstractBuild 'create', names, attrs

  @buildList:  (names, count, attrs) -> [0...count].map => @build names, attrs
  @createList: (names, count, attrs) -> [0...count].map => @create names, attrs

  @setupForEmber: (namespace) ->
    unless namespace? then throw new Error("undefined \"#{namespace}\"")

    class Factory.EmberDataAdapter extends Factory.Adapter
      build: (name, attrs) -> Ember.run => namespace.__container__.lookup('store:main').createRecord name, attrs
      create: (name, attrs) -> @build name, attrs
      push: (name, object) -> Ember.run => @get(name).addObject object

    Factory.adapter = Factory.EmberDataAdapter

if module?.exports then module.exports = Factory else window.Factory = Factory
