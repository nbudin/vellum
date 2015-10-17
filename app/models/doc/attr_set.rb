class Doc::AttrSet < Array
  class EditException < Exception
    attr_reader :errors
  
    def initialize(errors)
      @errors = errors
    end
  end
  
  def initialize(doc, doc_version = nil)
    @deleted_attrs = []
    @doc = doc
    @attrs_by_slug = {}
    
    unless doc_version.nil?
      doc_version.attrs.each do |attr|
        # We create a clone of the attr with the version ref removed
        # but the @doc variable remaining set

        self.push(attr.shim_for_attr_set(@doc), true)
      end
    end
    update_slug_hash!

    # ensure we have all template attributes
    unless @doc.doc_template.nil?
      @doc.doc_template.doc_template_attrs.each do |dta|
        slug = Attr::WithSlug.slug_for(dta.name)
        unless @attrs_by_slug.has_key?(slug)
          new_attr = Attr.new(:name => dta.name, :doc => @doc)
          self.push(new_attr, true)
        end
      end
    end
    
    after_change
  end

  def [](index_or_slug)
    case index_or_slug
    when Fixnum
      super(index_or_slug)
    else
      existing = find_by_index_or_slug(index_or_slug)

      if existing.nil?
        new_attr = Attr.new(:name => index_or_slug, :doc => @doc)
        self << new_attr
        return new_attr
      else
        return existing
      end
    end
  end

  def <<(attr)
    super(attr)
    after_change
  end

  def push(attr, skip_update = false)
    super(attr)
    after_change unless skip_update
  end

  def insert(index, attr)
    super(index, attr)
    after_change
  end

  def after_change
    update_slug_hash!
    resort!
  end

  def update_slug_hash!
    @attrs_by_slug = self.inject({}) do |memo, attr|
      memo[attr.slug] = attr
      memo
    end      
  end

  def resort!
    self.sort! do |a, b|
      if a.from_template? && !b.from_template?
        -1
      elsif !a.from_template? && b.from_template?
        1
      elsif a.position && b.position
        a.position <=> b.position
      elsif a.position
        -1
      elsif b.position
        1
      else
        a.name <=> b.name
      end
    end
  end

  def find_by_index_or_slug(index_or_slug)
    case index_or_slug
    when Fixnum
      self[index_or_slug]
    else
      slug = Attr::WithSlug.slug_for(index_or_slug)
      @attrs_by_slug[slug] #||= self.select { |attr| attr.slug == slug }.first
    end
  end

  def delete(index_or_slug)
    attr = find_by_index_or_slug(index_or_slug)
    return unless attr

    super(attr)
    @attrs_by_slug.delete(attr.slug)
    @deleted_attrs << attr
    resort!
    return attr
  end

  def save_to_doc_version(doc_version)
    doc_version.attrs = self.collect { |attr| attr.clone }

    doc_version.attrs.each do |attr|
      attr.doc_version = doc_version
    end
  end

  def changed?
    @deleted_attrs.size > 0 or self.any? do |attr|
      attr_changes = attr.changes.keys
      attr_changes -= ["doc_version_id"]
      attr_changes.size > 0
    end
  end

  def nested_attributes
    self.inject([]) do |memo, attr|
      memo << { 'name' => attr.name, 'value' => attr.value }
      memo
    end
  end

  def nested_attributes=(nested_attributes = [])
    errors = []
    
    nested_attributes_array = case nested_attributes
    when Array
      nested_attributes
    when Hash
      nested_attributes.keys.sort.inject([]) do |memo, key|
        memo << nested_attributes[key]
      end
    else
      raise "Nested attributes must be an array or hash"
    end
    
    nested_attributes_array.reject! { |item| item['name'].blank? && item['value'].blank? }
    
    #first pass: eliminate dupes
    seen = Set.new
    dupes = Set.new
    nested_attributes_array.each do |item|
      name = item['name']
      next unless name
      
      if seen.include?(name)
        errors << "Duplicate attribute name '#{name}'"
      else
        seen << name
      end
    end
    
    #second pass: do the edit
    nested_attributes_array.each do |item|
      name = item['name']
      if name.nil?
        errors << "Item #{item.inspect} has no specified name"
        next
      end
      
      next if dupes.include?(name)
      
      if ActiveRecord::Type::Boolean.new.type_cast_from_database(item['_destroy']) ||
          ActiveRecord::Type::Boolean.new.type_cast_from_database(item['_delete'])
        self.delete(name)
      else
        self[name].value = item['value'] if item.has_key?('value')
        self[name].multiple_value = item['multiple_value'] if item.has_key?('multiple_value')
      end
    end
    
    if errors.size > 0
      raise Doc::AttrSet::EditException.new(errors)
    end
    
    self.nested_attributes
  end
  
  def as_json(options={})
    collect { |attr| attr.as_json(options) }
  end
end