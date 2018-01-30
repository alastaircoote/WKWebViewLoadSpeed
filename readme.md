# Testing the load time of WKWebViews

In experimenting with in-app webviews I've noticed that the WKWebView can sometimes be slow to load. So I did a couple of quick experiments to see if I could improve that, which are contained in this app.

(I warn you now, the code is terrible, but this is just a quick test I figured I might as well publish)

![GIF comparison](https://thumbs.gfycat.com/CourteousMediumAssassinbug-size_restricted.gif)

It gives you buttons to try out three load modes, as well as turning load timing on and off. The WKWebView's load handler doesn't seem to bear any relation to whether the page is actually visible (I assume this is cross-process thing) so instead we take lots of screenshots in rapid succession to manually check when the page has visibly loaded.

But that code _itself_ has a performance impact, so the transitions are lot jerkier and the millisecond timing isn't really accurate. But it's still a good measure to see how the different loads perform relative to each other.

### Normal load

When you hit the button, a new WKWebView is created, and `loadHTMLString()` is called. Then the view is put into a new controller an pushed into the navigation controller.

### Pre-created load

The app creates a WKWebView "in waiting" whenever the previous webview is loaded successfully. So, by the time you tap on the "pre-created" button, a WKWebView already exists. On tap, `loadHTMLString()` is called and the view is
added to a controller and pushed.

### Injected content

I noticed that there is sometimes a delay in `loadHTMLString()` no matter what you do, so this takes the principle further. The pre-created webview has loadHTMLString() called on it _while waiting for the tap_, loading a totally blank page. Then, when you tap on the inject button, it runs evaluateJavascript() and manually injects the page HTML by setting `document.documentElement.innerHTML`.

## Initial results

There's a very clear difference between the normal loading and pre-created load - while the raw numbers aren't accurate (see above) it appears in about half the time. More crucially, the "blue flash" of the empty view controller transitioning onto the screen happens far less often (but does still happen from time to time).

There's a much smaller difference between pre-created vs injected. Sometimes it seems to have an effect but other times it doesn't, and it's not too clear why. It brings some weird restrictions with it (for one, you need to handle `script` tags manually because you can't inject them) so you may or may not want to implement it.
