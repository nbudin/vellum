RelationshipBuilder = Class.create({
    'initialize': function(parent, postUrl) {
	this.parent = $(parent);
	this.postUrl = postUrl;

	this.form = new Element('form', {'method': 'post', 'action': postUrl });
	this.parent.appendChild(this.form);

	this.relationshipTypeIdField = new Element('input', 
						   {'type': 'hidden', 
						    'name': 'relationship[relationship_type_id]'});
	this.form.appendChild(this.relationshipTypeIdField);
	this.relationshipOrigin = null;
	
	this.relationshipTypeSelect = new Element('select');
	this.relationshipTypeSelect.appendChild(new Element('option', {'value': ''}));
	this.relationshipTypeSelect.observe('change', this.buildTargetSelect.bind(this));
	this.form.appendChild(this.relationshipTypeSelect);

	this.targetSelect = new Element('select', {'style': 'display: none;'});
	this.form.appendChild(this.targetSelect);
    },

    'addRelationshipType': function(id, direction, description) {
	var option = new Element('option', {'value': id + '_' + direction});
	option.update(description);
	this.relationshipTypeSelect.appendChild(option);
    },

    'buildTargetSelect': function(event) {
	var idpdRegex = /^(\d+)_(\w+)$/;
	var idPlusDirection = event.element().value;
	var description = event.element().options[event.element().selectedIndex].innerHTML;
	var match = idpdRegex.exec(idPlusDirection);
	if (match) {
	    this.relationshipTypeIdField.value = match[1];
	    this.relationshipOrigin = match[2];
	    RelationshipType.find(match[1], function (rtype) {
		var otherTemplateId = null;
		if (this.relationshipOrigin == "left") {
		    otherTemplateId = rtype.right_template_id;
		} else if (this.relationshipOrigin == "right") {
		    otherTemplateId = rtype.left_template_id;
		}
		if (otherTemplateId) {
		    otherTemplate = StructureTemplate.find(otherTemplateId);
		    Structure.find('all', {'template_id': otherTemplateId}, function(structures) {
			this.targetSelect.childElements().each(function(node) {
			    node.remove();
			});

			var newOption = new Element('option', {'value': 'new'});
			newOption.update("New "+otherTemplate.name+"...");
			this.targetSelect.appendChild(newOption);

			structures.each(function(structure) {
			    var option = new Element('option', {'value': structure.id});
			    option.update(structure.name);
			    this.targetSelect.appendChild(option);
			}.bind(this));

			this.targetSelect.show();
		    }.bind(this));
		}
	    }.bind(this));
	}
    }
});

