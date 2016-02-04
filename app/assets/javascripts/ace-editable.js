// define('ace/mode/vpub', function(require, exports, module) {
//   var oop = require("ace/lib/oop");
//   var XmlMode = require("ace/mode/xml").Mode;
//   var ExampleHighlightRules = require("ace/mode/example_highlight_rules").ExampleHighlightRules;
//
//   var Mode = function() {
//       this.HighlightRules = ExampleHighlightRules;
//   };
//   oop.inherits(Mode, XmlMode);
//
//   (function() {
//       // Extra logic goes here. (see below)
//   }).call(Mode.prototype);
//
//   exports.Mode = Mode;
//   });
//
//   define('ace/mode/example_highlight_rules', function(require, exports, module) {
//
//   var oop = require("ace/lib/oop");
//   var TextHighlightRules = require("ace/mode/text_highlight_rules").TextHighlightRules;
//
//   var ExampleHighlightRules = function() {
//
//       this.$rules = new TextHighlightRules().getRules();
//
//   }
//
//   oop.inherits(ExampleHighlightRules, TextHighlightRules);
//
//   exports.ExampleHighlightRules = ExampleHighlightRules;
// });

var VPUB_TAGS = [
  'v:name',
  'v:content',
  'v:each_doc',
  'v:attr:value',
  'v:attr:if_value',
  'v:each_related',
  'v:include',
  'v:repeat',
  'v:yield'
];

jQuery(function() {
  var vpubTagCompleter = {
    getCompletions: function(editor, session, pos, prefix, callback) {
      var token = session.getTokenAt(pos.row, pos.column);

      if (token.type === 'meta.tag.tag-name.xml') {
        if (token.value.match(/^v:/)) {
          return VPUB_TAGS.map(function (tag) {
            return {
              value: tag,
              meta: "tag",
              score: Number.MAX_VALUE
            };
          });
        }
      }
    }
  }

  jQuery(".ace-editable").each(function () {
    var editorDiv = jQuery("<div class=\"form-control\"></div>");
    var $this = jQuery(this);
    $this.hide().after(editorDiv);

    var langTools = ace.require("ace/ext/language_tools");
    var editor = ace.edit(editorDiv.get(0));
    editor.setOptions({enableBasicAutocompletion: true, enableLiveAutocompletion: true});
    editor.setTheme("ace/theme/textmate");
    editor.getSession().setMode($this.attr('data-ace-mode'));
    editor.getSession().setUseSoftTabs(true);
    editor.setValue($this.val());
    editor.selection.selectFileStart();

    langTools.addCompleter(vpubTagCompleter);

    $this.closest('form').submit(function() {
      $this.val(editor.getValue());
    });
  });
});