class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    @query = params[:q].to_s.strip

    if @query.present?
      @programs = Program.where("name ILIKE ?", "%#{@query}%").order(:name)
      @contracts = Contract.where("contract_code ILIKE ?", "%#{@query}%").order(:contract_code)
      @docs = Docs::Repository.search(@query)
    else
      @programs = []
      @contracts = []
      @docs = []
    end
  end
end
