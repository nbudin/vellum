RelationshipBuilder = Class.create({
    'initialize': function(parent, sourceId, postUrl, buttonImageUrl) {
		this.parent = $(parent);
		this.sourceId = sourceId;
		this.postUrl = postUrl;
		this.buttonImageUrl = buttonImageUrl;
	
		this.form = new Element('form', {'method': 'post', 'action': postUrl });
		this.parent.appendChild(this.form);
	
		this.buttonFloat = new Element('div', {'style': 'float: right;'});
		this.addButton = new Element('button', {'class': 'new', 'disabled': 'disabled'});
		if (this.buttonImageUrl) {
			this.buttonImage = new Element('img', {'src': this.buttonImageUrl});
			this.addButton.appendChild(this.buttonImage);
		}
		this.addButton.insert(' Add');
		this.buttonFloat.appendChild(this.addButton);
	
		this.form.appendChild(this.buttonFloat);
	
		this.relationshipTypeIdField = new Element('input', 
							   {'type': 'hidden', 
								'name': 'relationship[relationship_type_id]'});
		this.form.appendChild(this.relationshipTypeIdField);
		this.relationshipOrigin = null;
		
		this.relationshipTypeSelect = new Element('select');
		this.relationshipTypeSelect.appendChild(new Element('option', {'value': ''}));
		this.relationshipTypeSelect.observe('change', this.relationshipTypeChanged.bind(this));
		this.form.appendChild(this.relationshipTypeSelect);
	
		this.targetSelect = new Element('select', {'style': 'display: none;'});
		this.targetSelect.observe('change', this.targetChanged.bind(this));
		this.form.appendChild(this.targetSelect);
	
		this.leftId = new Element('input', {'type': 'hidden', 'name': 'relationship[left_id]'});
		this.form.appendChild(this.leftId);
		this.rightId = new Element('input', {'type': 'hidden', 'name': 'relationship[right_id]'});
		this.form.appendChild(this.rightId);
	},

    'addRelationshipType': function(id, direction, description) {
		var option = new Element('option', {'value': id + '_' + direction});
		option.update(description);
		this.relationshipTypeSelect.appendChild(option);
    },

    'relationshipTypeChanged': function(event) {
		var idpdRegex = /^(\d+)_(\w+)$/;
		var idPlusDirection = event.element().value;
		var description = event.element().options[event.element().selectedIndex].innerHTML;
		var match = idpdRegex.exec(idPlusDirection);
		this.targetSelect.childElements().each(function(node) {
			node.remove();
		});
	
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
						var blankOption = new Element('option', {'value': ''});
						this.targetSelect.appendChild(blankOption);
			
						var newOption = new Element('option', {'value': 'new'});
						newOption.update("<b>New "+otherTemplate.name+"...</b>");
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
		} else {
			this.targetSelect.hide();
			this.targetChanged(event);
		}
    },

    'targetChanged': function(event) {
		if (this.targetSelect.value) {
			if (this.addButton.hasAttribute('disabled')) {
			this.addButton.removeAttribute('disabled');
			}
			if (this.relationshipOrigin == 'left') {
			this.leftId.value = this.sourceId;
			this.rightId.value = this.targetSelect.value;
			} else {
			this.leftId.value = this.targetSelect.value;
			this.rightId.value = this.sourceId;
			}
		} else {
			this.addButton.writeAttribute({'disabled': 'disabled'});
			this.leftId.value = null;
			this.rightId.value = null;
		}
    }
});

