class DocsController < ApplicationController
  before_action :authenticate_user!

  def index
    @query = params[:q].to_s.strip
    @sections = Docs::Repository.grouped_by_category
    @results = @query.present? ? Docs::Repository.search(@query) : []
  end

  def show
    @doc = Docs::Repository.find(params[:slug])
    raise ActiveRecord::RecordNotFound unless @doc
  end
end
