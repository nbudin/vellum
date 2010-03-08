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
    
    function updateMarkForDeletionClass(checkbox) {
        if (checkbox == null) {
            checkbox = this;
        }
        checkbox = jQuery(checkbox);
        var target = checkbox.parents('dd');

        if (checkbox.is(':checked')) {
            target.addClass('willDelete');
        } else {
            target.removeClass('willDelete');
        }
    }

    function toggleDeleteCheckbox(event) {
        var checkbox = event.data;

        if (checkbox.is(':checked')) {
            checkbox.attr('checked', false);
        } else {
            checkbox.attr('checked', true);
        }

        updateDeleteButtonText(checkbox);
        updateMarkForDeletionClass(checkbox);
    }

    function updateDeleteButtonText(checkbox) {
        if (checkbox == null) {
            checkbox = this;
        }
        checkbox = jQuery(checkbox);
        button = checkbox.siblings('button');

        if (checkbox.is(':checked')) {
            button.html("Keep");
        } else {
            button.html("Remove");
        }
    }

    function makeDeleteCheckboxAButton() {
        var $this = jQuery(this);
        var target = $this.parent();

        target.children().hide();
        var deleteButton = jQuery("<button type=\"button\" class=\"delete\">Remove</button>");
        deleteButton.bind('click', $this, toggleDeleteCheckbox);
        target.append(deleteButton);

        updateDeleteButtonText($this);
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
    this.children('dd').vellumTemplateAttr();

    var $lastAttr = this.children('dt:last, dd:last');
    var newAttrHtml = jQuery("<p>").append($lastAttr.clone()).html();

    var $newAttrDiv = jQuery("<p><button class=\"new\" type=\"button\">Add field</button></p>");
    $newAttrDiv.find("button").bind('click', {'list': this, 'newAttrDiv': $newAttrDiv, 'rawHtml': newAttrHtml},
        function(event) {
            var timedHtml = event.data.rawHtml.replace(/99999/g, new Date().getTime());
            var newAttr = jQuery(timedHtml);

            var cancelButton = jQuery("<button class=\"delete\" type=\"button\">Remove</button>").
                bind("click", {'target': newAttr, 'list': event.data.list}, function(event) {
                    event.data.target.remove();
            });
            newAttr.filter('dd').append(jQuery("<span style=\"float: right\"></span>").append(cancelButton));
            newAttr.addClass('willAdd');

            newAttr.vellumTemplateAttr();
            event.data.newAttrDiv.before(newAttr);
        });
    $lastAttr.remove();
    this.append($newAttrDiv);
    
    return this;
}

jQuery.fn.slideUpAndRemove = function() {
    this.slideUp("fast", function() {
                jQuery(this).remove();
            });

    return this;
}

jQuery.fn.vellumDocSummaryPopup = function() {
    this.each(function () {
        var $this = jQuery(this);
        var href = $this.attr('href');
        $this.attr('href', "#");
        $this.attr('target', '');

        $this.bind('click', href, function (event) {
            jQuery('#docSummaryPopup').slideUpAndRemove();

            var href = event.data;
            var li = jQuery(this).parent();
            jQuery('li.expanded').removeClass('expanded');
            jQuery('a#closeDocSummaryPopup').remove();
            jQuery('a#popupDoc').remove();
            
            jQuery.getJSON(href + '.json', function(data) {
                console.log(data);
                
                var content = data.content;
                if (content == null || content.length == 0) {
                    content = "<p><i>No content</i></p>";
                }

                var popup = jQuery("<div id=\"docSummaryPopup\">" + content + "</div>");
                popup.hide();
                li.after(popup);
                li.addClass('expanded');

                var popupLink = jQuery("<a href=\"" + href + "\" target=\"blank\" style=\"float: right;\" id=\"popupDoc\">" +
                    "<img src=\"/images/popup.png\" alt=\"Pop up\" title=\"Pop up\"/></a>");

                var closeLink = jQuery("<a href=\"#\" id=\"closeDocSummaryPopup\" style=\"float: right;\">" +
                    "<img src=\"/images/contract.png\" alt=\"Close\" title=\"Close\"/></a>");
                closeLink.bind("click", function () {
                    jQuery('#docSummaryPopup').slideUpAndRemove();
                    jQuery('li.expanded').removeClass('expanded');
                    jQuery('a#closeDocSummaryPopup').remove();
                    jQuery('a#popupDoc').remove();
                });
                li.prepend(popupLink);
                li.prepend(closeLink);
                
                popup.slideDown("fast");
            });
        });
    });
}