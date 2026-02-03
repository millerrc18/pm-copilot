class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    @query = params[:q].to_s.strip

    if @query.present?
      program_query = "%#{@query.downcase}%"
      @programs = current_user.programs
        .where("LOWER(programs.name) LIKE ?", program_query)
        .order(:name)
      @contracts = Contract.joins(:program)
        .where(programs: { user_id: current_user.id })
        .where("LOWER(contracts.contract_code) LIKE ?", "%#{@query.downcase}%")
        .order(:contract_code)
      @docs = Docs::Repository.search(@query)
    else
      @programs = []
      @contracts = []
      @docs = []
    end
  end
end
