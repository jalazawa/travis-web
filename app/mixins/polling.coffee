`import Ember from 'ember'`

mixin = Ember.Mixin.create
  polling: Ember.inject.service()

  didInsertElement: ->
    @_super.apply(this, arguments)

    @startPolling()

  willDestroyElement: ->
    @_super.apply(this, arguments)

    @stopPolling()

  willDestroy: ->
    @_super.apply(this, arguments)

    @stopPolling()

  pollModelDidChange: (sender, key, value) ->
    @pollModel(key)

  pollModelWillChange: (sender, key, value) ->
    @stopPollingModel(key)

  pollModel: (property) ->
    model = @get(property)

    @get('polling').startPolling(model)

  stopPollingModel: (property) ->
    model = @get(property)

    @get('polling').stopPolling(model)

  startPolling: ->
    pollModels = @get('pollModels')

    if pollModels
      pollModels = [pollModels] unless pollModels.forEeach

      pollModels.forEach (property) =>
        @pollModel(property)
        @addObserver(property, this, 'pollModelDidChange')
        Ember.addBeforeObserver(this, property, this, 'pollModelWillChange')

    @get('polling').startPollingHook(this) if @pollHook

  stopPolling: ->
    pollModels = @get('pollModels')
    return unless pollModels

    pollModels = [pollModels] unless pollModels.forEeach

    pollModels.forEach (property) =>
      @stopPollingModel(property)
      @removeObserver(property, this, 'pollModelDidChange')
      Ember.removeBeforeObserver(this, property, this, 'pollModelWillChange')

    @get('polling').stopPollingHook(this)

`export default mixin`
