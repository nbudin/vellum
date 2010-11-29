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

jQuery.fn.vellumEditExpander = function () {
    this.each(function() {
        var $this = jQuery(this);
        var children = $this.children("*:visible").hide();
    
        var preview = jQuery("<div class=\"edit-expander-preview\" style=\"cursor: pointer;\">" 
            + $this.attr('data-edit-expander-preview') 
            + " <em>(click to edit)</em>"
            + "</div>");
        $this.prepend(preview);
        preview.bind('click', function () {
           preview.hide();
           children.show(); 
        });        
    });
    
    return this;
}

jQuery.fn.vellumAutoResizeWym = function () {
    var $wymIframe = this.find(".wym_iframe iframe");
    if ($wymIframe.size() == 0) {
        return this;
    }
    
    var doResize = function () {
        var targetHeight = jQuery(window).height() - $wymIframe.offset().top - 15;

        if (targetHeight < 200) {
            targetHeight = 200;
        }

        $wymIframe.height(targetHeight);
    };
    
    var initLoop = function() {
        // bit of a hack.  wait for the iframe height to be 200 before doing the initial resize.
        
        if ($wymIframe.height() < 200) {
            setTimeout(initLoop, 100);
        } else {
            doResize();
        }
    };
    
    var autoResizeTimer;
    jQuery(window).resize(function () {
        clearTimeout(autoResizeTimer);
        autoResizeTimer = setTimeout(doResize, 100);
    });
    
    initLoop();
    
    return this;
}

jQuery(function() {
  jQuery(".wymeditor").wymeditor({
    'skin': 'vellum',
    toolsItems: [
       {'name': 'Bold', 'title': 'Strong', 'css': 'wym_tools_strong'}, 
       {'name': 'Italic', 'title': 'Emphasis', 'css': 'wym_tools_emphasis'},
       {'name': 'InsertOrderedList', 'title': 'Ordered_List', 'css': 'wym_tools_ordered_list'},
       {'name': 'InsertUnorderedList', 'title': 'Unordered_List', 'css': 'wym_tools_unordered_list'},
//           {'name': 'Indent', 'title': 'Indent', 'css': 'wym_tools_indent'},
//           {'name': 'Outdent', 'title': 'Outdent', 'css': 'wym_tools_outdent'},
       {'name': 'Undo', 'title': 'Undo', 'css': 'wym_tools_undo'},
       {'name': 'Redo', 'title': 'Redo', 'css': 'wym_tools_redo'},
//           {'name': 'InsertImage', 'title': 'Image', 'css': 'wym_tools_image'},
       {'name': 'ToggleHtml', 'title': 'HTML', 'css': 'wym_tools_html'},
       {'name': 'Paste', 'title': 'Paste_From_Word', 'css': 'wym_tools_paste'}
     ],
     containersItems: [
       {'name': 'P', 'title': 'Paragraph', 'css': 'wym_containers_p'},
       {'name': 'H1', 'title': 'Heading_1', 'css': 'wym_containers_h1'},
       {'name': 'H2', 'title': 'Heading_2', 'css': 'wym_containers_h2'},
       {'name': 'H3', 'title': 'Heading_3', 'css': 'wym_containers_h3'},
       {'name': 'H4', 'title': 'Heading_4', 'css': 'wym_containers_h4'},
       {'name': 'H5', 'title': 'Heading_5', 'css': 'wym_containers_h5'},
       {'name': 'H6', 'title': 'Heading_6', 'css': 'wym_containers_h6'}
     ],
     logoHtml: '',
     iframeBasePath: '/javascripts/wymeditor/iframe/vellum/',
     postInit: function(wym) {
       wym.parser._Listener.block_tags.push("u");
       
         //add the 'Wrap' translation (used here for the dialog's title)
         jQuery.extend(WYMeditor.STRINGS['en'], {
             'Underline': 'Underline'
         });

         //construct the wrap button's html
         //note: the button image needs to be created ;)
         var html = "<li class='wym_tools_underline'>"
                  + "<a href='#'"
                  + " title='Underline'"
                  + " style='background-image:"
                  + " url(/images/text_underline.png); "
                  + " background-position: 50% 50%;'>"
                  + "Underline"
                  + "</a></li>";

         //add the button to the tools box
         jQuery(html).insertAfter(jQuery(wym._box)
          .find(wym._options.toolsSelector + wym._options.toolsListSelector + ' .wym_tools_emphasis'));
         
         //handle click event on wrap button
         jQuery(wym._box)
         .find('li.wym_tools_underline a').click(function() {
             wym._doc.execCommand("Underline", '', null);
             return(false);
         });
         
     }
  });
  
  jQuery(".vellumEditExpander").vellumEditExpander();
  jQuery(".vellumAutoResizeWym").vellumAutoResizeWym();
});