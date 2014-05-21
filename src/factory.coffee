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

  @abstractBuildList: (buildType, names, list, attrs) ->
    if typeof list is 'number'
      [0...list].map => @abstractBuild buildType, names, attrs
    else if list instanceof Array
      list.map (listItem) =>
        if typeof listItem is 'string'
          @abstractBuild buildType, "#{names} #{listItem}", attrs
        else if listItem.constructor == Object
          @abstractBuild buildType, names, @hash.merge({}, attrs, listItem)
        else
          listItem

  @attributes: (names, attrs) -> @abstractBuild 'attributes', names, attrs
  @build:      (names, attrs) -> @abstractBuild 'build', names, attrs
  @create:     (names, attrs) -> @abstractBuild 'create', names, attrs

  @buildList:  (names, list, attrs) -> @abstractBuildList 'build', names, list, attrs
  @createList: (names, list, attrs) -> @abstractBuildList 'create', names, list, attrs

  @setupForEmber: (namespace) ->
    unless namespace? then throw new Error("undefined \"#{namespace}\"")

    class Factory.EmberDataAdapter extends Factory.Adapter
      build: (name, attrs) -> Ember.run -> namespace.__container__.lookup('store:main').createRecord name, attrs
      create: (name, attrs) -> @build name, attrs
      push: (name, object) -> Ember.run => @get(name).addObject object

    Factory.adapter = Factory.EmberDataAdapter

  @hash:
    merge: (dest, objs...) ->
      for obj in objs
        dest[k] = v for k, v of obj
      dest

    evaluate: (obj) ->
      for k of obj
        obj[k] =  if typeof obj[k] is 'function' then obj[k]() else obj[k]

if module?.exports then module.exports = Factory else window.Factory = Factory
