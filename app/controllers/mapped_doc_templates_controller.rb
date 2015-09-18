class MappedDocTemplatesController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :map, :through => :project
  load_and_authorize_resource :mapped_doc_template, :through => :map

  # POST /mapped_doc_templates
  # POST /mapped_doc_templates.xml
  def create
    respond_to do |format|
      if @mapped_doc_template.save
        format.html { redirect_to :back }
        format.xml  { render :xml => @mapped_doc_template, :status => :created, :location => @mapped_doc_template }
      else
        format.html { redirect_to :back }
        format.xml  { render :xml => @mapped_doc_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mapped_doc_templates/1
  # PUT /mapped_doc_templates/1.xml
  def update
    respond_to do |format|
      if @mapped_doc_template.update_attributes(mapped_doc_template_params)
        format.html { redirect_to :back }
        format.xml  { head :ok }
      else
        format.html { redirect_to :back }
        format.xml  { render :xml => @mapped_doc_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mapped_doc_templates/1
  # DELETE /mapped_doc_templates/1.xml
  def destroy
    @mapped_doc_template.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.xml  { head :ok }
    end
  end
  
  private
  def mapped_doc_template_params
    params.fetch(:mapped_doc_template, {}).permit(:doc_template_id, :color)
  end
end
