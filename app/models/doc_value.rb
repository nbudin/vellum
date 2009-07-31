class DocValue < ActiveRecord::Base
  include AttrValue

  belongs_to :doc

  validate :check_doc_in_project
  after_update :save_doc
  validates_associated :doc

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
  
  def author_id
    doc.author.id
  end
  
  def author_id=(author_id)
    doc.author_id = author_id
  end

  private
  def check_doc_in_project
    myproj = structure ? structure.project : nil
    if myproj and doc
      if doc.project
        unless doc.project.id == myproj.id
          errors.add("doc", "is in project #{doc.project.name}, but #{structure.name} is in #{myproj.name}")
        end
      else
        doc.project = myproj
        doc.save
      end
    end
  end
  
  def save_doc
    doc.save(false)
  end
end
