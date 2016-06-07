/*jslint browser:true */
/*globals Elm */
var app = Elm.Editor.fullscreen();

app.ports.setCursorPosition.subscribe(function (position) {
    // there has to be a better way than this :(
    setTimeout(function  () {
        var el = document.getElementById("EditorContent");
        var range = document.createRange();
        var sel = window.getSelection();
        position = parseInt(position, 10);
        if (position > el.childNodes[0].length) {
            position = el.childNodes[0].length;
        }
        range.setStart(el.childNodes[0], position);
        range.collapse(true);
        sel.removeAllRanges();
        sel.addRange(range);
        el.focus();
        console.log(position);
    }, 16);
});
