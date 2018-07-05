module Window {
  /* Navigates to the given URL. */
  fun navigate (url : String) : Void {
    `_navigate(url)`
  }

  /* Sets the URL of the window without navigating to it. */
  fun setUrl (url : String) : Void {
    `_navigate(url, false)`
  }

  /* Returns the windows title. */
  fun title : String {
    `document.title`
  }

  /* Sets the windows title. */
  fun setTitle (title : String) : Void {
    `document.title = title`
  }

  /* Returns the current `Url` of the window. */
  fun url : Url {
    Url.parse(href())
  }

  /* Returns the windows URL as a string. */
  fun href : String {
    `window.location.href`
  }

  /* Returns the width of the window in pixels. */
  fun width : Number {
    `window.innerWidth`
  }

  /* Returns the height of the window in pixels. */
  fun height : Number {
    `window.innerHeight`
  }

  /* Returns the scrollable height of the window in pixels. */
  fun scrollHeight : Number {
    `document.body.scrollHeight`
  }

  /* Returns the scrollable width of the window in pixels. */
  fun scrollWidth : Number {
    `document.body.scrollWidth`
  }

  /* Returns the horizontal scroll position of the window in pixels. */
  fun scrollLeft : Number {
    `document.body.scrollLeft`
  }

  /* Returns the vertical scroll position of the window in pixels. */
  fun scrollTop : Number {
    `document.body.scrollTop`
  }

  /* Sets the horizontal scroll position of the window in pixels. */
  fun setScrollTop (position : Number) : Void {
    `window.scrollTo(this.scrollTop(), position)`
  }

  /* Sets the vertical scroll position of the window in pixels. */
  fun setScrollLeft (position : Number) : Void {
    `window.scrollTo(position, this.scrollLeft())`
  }
}
