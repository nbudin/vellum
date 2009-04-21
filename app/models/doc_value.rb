class DocValue < ActiveRecord::Base
  include AttrValue

  belongs_to :doc

  validate :check_doc_in_project

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
  end

  private
  def check_doc_in_project
    myproj = structure and structure.project
    if myproj
      if doc.project
        unless doc.project == myproj
          errors.add("doc", "Doc does not belong to the same project as this DocValue")
        end
      else
        doc.project = myproj
        doc.save
      end
    end
  end
end
