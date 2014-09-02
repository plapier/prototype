---
---
class PanelEvents
  constructor: ->
    @maxOffsetLeft = Math.round(window.innerWidth * 0.8)
    @menuWidth = undefined
    @left = 2
    @right = 4
    @menu = document.getElementById('primary-menu')
    @main = document.getElementById('sliding-panel')
    @$main = $(@main)

    @animationEndListener()
    @menuButtonListener()
    @menuNavListener()

    @hammertime = new Hammer(@main)
    @hammerSetup()

  toggleMenu: (val, animate) ->
    @main.classList.add 'animate' if animate?

    open = =>
      document.body.classList.add 'prevent-scroll'
      @main.classList.remove "slide-left"
      @main.classList.add "slide-right"
      @menu.className = 'open'

    close = =>
      document.body.classList.remove 'prevent-scroll'
      @main.classList.remove "slide-right"
      @main.classList.add "slide-left"
      @menu.className = 'close'

    @main.style.webkitTransform = ""
    switch val
      when 'open' then open()
      when 'close' then close()

  animationEndListener: ->
    @$main.on 'webkitAnimationEnd', (e) =>
      @main.classList.remove('animate', 'slide-left')

  menuButtonListener: ->
    $('.menu-button').on 'touchend click', (e) =>
      e.preventDefault()
      switch @main.classList.contains('slide-right')
        when true then @toggleMenu('close', true)
        when false then @toggleMenu('open', true)

  menuNavListener: ->
    $('.menu-nav').on 'touchend click', 'a', (e) =>
      e.preventDefault()
      id = $(e.currentTarget).parent().attr 'data-id'
      $(e.currentTarget).parent().addClass('active').siblings().removeClass('active')
      $("section.#{id}").addClass('active').siblings().removeClass('active')
      @toggleMenu('close', true)

  hammerSetup: ->
    @hammertime.on "panstart panend panleft panright swiperight tap", @hammerFn
    @hammertime.get("pan").set
      direction: Hammer.DIRECTION_HORIZONTAL
      threshold: 10
    @hammertime.get("swipe").set
      velocity: 0.45

  hammerFn: (ev) =>
    if ev.type is 'swiperight'
      return if @main.classList.contains('slide-right')
      @toggleMenu('open')
      return

    return if !@main.classList.contains('slide-right')

    if ev.type is 'tap'
      return if @main.classList.contains('animate')
      @toggleMenu('close', true)
      return

    if ev.type is 'panstart'
      @menuWidth = @$main.offset().left
      @main.classList.add('drag')
      return

    if ev.type is 'panleft' or 'panright'
      delta = Math.round(@menuWidth + ev.deltaX)
      switch
        when delta < 0 then delta = 0
        when delta > @maxOffsetLeft then delta = @maxOffsetLeft
      @main.style.webkitTransform = "translate3D(#{delta}px, 0, 0)"

    if ev.type is "panend"
      @main.classList.remove('drag')
      @menuWidth = @$main.offset().left

      toggleMenuUsingPosition =  =>
        if @menuWidth > (window.innerWidth * 0.5)
          @toggleMenu('open')
        else
          @toggleMenu('close')

      switch ev.direction
        when @left then @toggleMenu('close')
        when @right then @toggleMenu('open')
        else toggleMenuUsingPosition()
      return

$ ->
  new PanelEvents
