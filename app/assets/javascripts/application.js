// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require ace/ace
//= require ace/mode-html
//= require_tree .

window.editor = ace.edit("editor");
var HTMLMode = require("ace/mode/html").Mode;

editor.getSession().setMode(new HTMLMode());
editor.getSession().setTabSize(2);
editor.getSession().setUseSoftTabs(true);

$('form').submit(function() {
  $('#contents').val(editor.getValue());
});
