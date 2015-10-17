class Doc::Version < ActiveRecord::Base
  belongs_to :doc
  belongs_to :author, :class_name => "::Person"
  has_many :attrs, :class_name => "::Attr", :foreign_key => "doc_version_id", :autosave => true  
  has_one :doc_template, through: :doc
  has_one :project, through: :doc
  
  def description
    "#{human_version_number} - #{author_name} - #{created_at.try { to_date.to_formatted_s(:short_with_year) }}"
  end
  
  def human_version_number
    if is_latest?
      "current"
    else
      "v#{version}"
    end
  end
  
  def is_latest?
    doc.latest_version == self
  end
  
  def previous_version
    @previous_version ||= begin
      doc.versions.order(:version)[version_index - 1] if version_index > 0
    end
  end
  
  def next_version
    @next_version ||= begin
      doc.versions.order(:version)[version_index + 1] if version_index < doc.versions.size - 1
    end
  end
  
  def version_index
    @version_index ||= doc.versions.order(:version).index(self)
  end
  
  def author_name
    author.try(:name) || "unknown author"
  end
  
  def attrs_attributes
    Doc::AttrSet.new(doc, self).nested_attributes
  end
end