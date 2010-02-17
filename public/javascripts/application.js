// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

(function(jQuery) {
    function updateChoicesVisibility() {
        var $this = jQuery(this);
        var value = $this.val();
        var target = $this.parents('dd').find('.choices');

        if (value == "radio" || value == "dropdown" || value == "multiple") {
          target.show();
        } else {
          target.hide();
        }
    }
    
    function updateMarkForDeletionClass() {
        var $this = jQuery(this);
        var target = $this.parents('dd');

        if ($this.is(':checked')) {
            target.addClass('markedForDeletion');
        } else {
            target.removeClass('markedForDeletion');
        }
    }

    function makeDeleteCheckboxAButton() {
        var $this = jQuery(this);
        var target = $this.parent();

        target.children().hide();
        var deleteButton = jQuery("<button type=\"button\" class=\"delete\">Remove</button>");
        deleteButton.bind('click', $this, function(event) {
            var $this = jQuery(this);

            if (event.data.is(':checked')) {
                event.data.attr('checked', false);
                $this.html("Remove");
            } else {
                event.data.attr('checked', true);
                $this.html("Keep");
            }

            updateMarkForDeletionClass(event.data);
        })
        target.append(deleteButton);
    }

    jQuery.fn.vellumTemplateAttr = function() {
        this.find('select.ui_type_select')
            .bind('change', updateChoicesVisibility)
            .each(updateChoicesVisibility);

        this.find('input[type=checkbox].delete')
            .bind('change', updateMarkForDeletionClass)
            .each(updateMarkForDeletionClass)
            .each(makeDeleteCheckboxAButton);

        return this;
    }
})(jQuery);

jQuery.fn.zebrify = function(selector) {
    var children = this.children(selector);

    // stupid zero-based indexing: :even gives you the odd ones and vice versa
    children.filter(":even").removeClass("even").addClass("odd");
    children.filter(":odd").removeClass("odd").addClass("even");
}

jQuery.fn.vellumAttrList = function() {
    this.children('div').vellumTemplateAttr();

    var $lastAttr = this.children('div:last-child');
    var newAttrHtml = $lastAttr.html();

    var $newAttrDiv = jQuery("<dd><button class=\"new\" type=\"button\">Add field</button></dd>");
    $newAttrDiv.find("button").bind('click', {'list': this, 'newAttrDiv': $newAttrDiv, 'rawHtml': newAttrHtml},
        function(event) {
            var timedHtml = event.data.rawHtml.replace(/99999/g, new Date().getTime());
            var newAttr = jQuery("<div>" + timedHtml + "</div>");

            var cancelButton = jQuery("<button class=\"delete\" type=\"button\">Remove</button>").
                bind("click", {'target': newAttr, 'list': event.data.list}, function(event) {
                    event.data.target.remove();
                    event.data.list.zebrify('div');
            });
            newAttr.find('dd').append(jQuery("<span style=\"float: right\"></span>").append(cancelButton));

            newAttr.vellumTemplateAttr();
            event.data.newAttrDiv.before(newAttr);
            event.data.list.zebrify('div');
        });
    $lastAttr.replaceWith($newAttrDiv);
    
    return this.zebrify('div');
}