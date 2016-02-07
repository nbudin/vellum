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

var vpubAttributeMap = {
  'v:name': [],
  'v:content': [],
  'v:each_doc': ['template', 'sort'],
  'v:attr:value': ['name'],
  'v:attr:if_value': ['name', 'eq', 'ne', 'match'],
  'v:each_related': ['how'],
  'v:include': ['template', 'sort'],
  'v:repeat': ['times'],
  'v:yield': []
};

var vpubElements = Object.keys(vpubAttributeMap);

var VPubTagCompleter = {
  getCompletions: function(editor, session, pos, prefix, callback) {
    var token = session.getTokenAt(pos.row, pos.column);

    if (token.type === 'meta.tag.tag-name.xml') {
      if (token.value.match(/^v:/)) {
        var completions = vpubElements.map(function (tag) {
          return {
            value: tag.slice(2),
            meta: "tag",
            score: Number.MAX_VALUE
          };
        });

        callback(null, completions);
      }
    }
  }
};

var VPubAttrCompleter = {
  findTagName: function(session, pos) {
      var iterator = new TokenIterator(session, pos.row, pos.column);
      var token = iterator.getCurrentToken();
      while (token && !is(token, "tag-name")){
          token = iterator.stepBackward();
      }
      if (token)
          return token.value;
  },

  getCompletions: function(state, session, pos, prefix) {
      var tagName = VPubAttrCompleter.findTagName(session, pos);
      if (!tagName)
          return [];
      var attributes = [];
      if (tagName in vpubAttributeMap) {
          attributes = attributeMap[tagName];
      }
      return attributes.map(function(attribute){
          return {
              caption: attribute,
              snippet: attribute + '="$0"',
              meta: "attribute",
              score: Number.MAX_VALUE
          };
      });
  }
};

jQuery(function() {
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

    langTools.addCompleter(VPubTagCompleter);
    langTools.addCompleter(VPubAttrCompleter);

    $this.closest('form').submit(function() {
      $this.val(editor.getValue());
    });
  });
});