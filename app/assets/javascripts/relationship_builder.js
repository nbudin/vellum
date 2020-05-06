(function(jQuery) {
    updateTargets = function() {
        var $this = jQuery(this);
        var $form = $this.parent();
        var $targetIdSelect = $form.find('select[name="relationship[target_id]"]');
		var idpdRegex = /^(\d+)_(left|right)$/;
        var idPlusDirection = $this.val();
		var description = $this.find('option:selected').html();
		var match = idpdRegex.exec(idPlusDirection);
		var projectURL = $form.attr('data-project-url');

		if (match) {
            var relationshipTypeId = match[1];
            var sourceDirection = match[2];

		    $targetIdSelect.find('option').remove();
		    jQuery.getJSON(projectURL + '/relationship_types/'+relationshipTypeId+'.json', function (rtype) {

				var otherTemplateId = null;
				if (sourceDirection == "left") {
					otherTemplateId = rtype.right_template_id;
				} else if (sourceDirection == "right") {
					otherTemplateId = rtype.left_template_id;
				}
				jQuery.getJSON(projectURL + '/docs.json?template_id=' + otherTemplateId, function(docs) {
				    $targetIdSelect.append('<option value=""></option>');
                    $targetIdSelect.append('<option value="new"><b>New document...</b></option>');

			        for (var i=0; i<docs.length; i++) {
			            var doc = docs[i];
                        var $docOption = jQuery('<option value="'+doc.id+'"></option>');
                        $docOption.html(doc.name);
                        $targetIdSelect.append($docOption);
			        }

			        $targetIdSelect.show();
			        enableDisableButton();
				});
			});
		} else {
			$targetIdSelect.hide();
			enableDisableButton();
		}
    };

    enableDisableButton = function () {
        var $this = jQuery(this);
        var $form = $this.parent();
        var $button = $form.find('button');

        if ($form.find('select').filter(function () { return (jQuery(this).val() == '') }).length > 0) {
            $button.attr('disabled', 'disabled');
        } else {
            $button.removeAttr('disabled');
        }
    };

    jQuery.fn.vellumRelationshipBuilder = function() {
        this.find('select[name="relationship[relationship_type_id_and_source_direction]"]')
            .bind('change', updateTargets);

        this.find('select[name="relationship[target_id]"]')
            .bind('change', enableDisableButton)
            .hide()
            .each(enableDisableButton);

        return this;
    }
}(jQuery));

jQuery(function() {
    jQuery(".vellumRelationshipBuilder").vellumRelationshipBuilder();
});
