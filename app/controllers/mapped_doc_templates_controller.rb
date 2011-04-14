class MappedDocTemplatesController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :map, :through => :project
  load_and_authorize_resource :mapped_doc_template, :through => :map

  # POST /mapped_doc_templates
  # POST /mapped_doc_templates.xml
  def create
    @mapped_doc_template = @map.mapped_doc_templates.new(params[:mapped_doc_template])

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
    @mapped_doc_template = @map.mapped_doc_templates.find(params[:id])

    respond_to do |format|
      if @mapped_doc_template.update_attributes(params[:mapped_doc_template])
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
    @mapped_doc_template = @map.mapped_doc_templates.find(params[:id])
    @mapped_doc_template.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.xml  { head :ok }
    end
  end
end
