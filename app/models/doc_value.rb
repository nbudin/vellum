class DocValue < ActiveRecord::Base
  include AttrValue

  belongs_to :doc

  def html_rep
    doc ? doc.content : ""
  end

  def doc_content
    doc ? doc.content : nil
  end

  def doc_content=(content)
    if doc.nil?
      build_doc
    end
    doc.content = content
    doc.save
  end
end
