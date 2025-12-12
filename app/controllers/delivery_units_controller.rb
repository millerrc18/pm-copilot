class DeliveryUnitsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_contract, only: %i[index new create]
  before_action :set_delivery_unit, only: %i[show edit update destroy]

  def index
    @units = @contract.delivery_units.order(:ship_date, :unit_serial)
  end

  def show
  end

  def new
    @delivery_unit = @contract.delivery_units.build
  end

  def create
    @delivery_unit = @contract.delivery_units.build(delivery_unit_params)

    if @delivery_unit.save
      redirect_to contract_path(@contract), notice: "Delivered unit added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @delivery_unit.update(delivery_unit_params)
      redirect_to contract_path(@contract), notice: "Delivered unit updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @delivery_unit.destroy
    redirect_to contract_path(@contract), notice: "Delivered unit deleted."
  end

  private

  def set_contract
    @contract = Contract.joins(:program)
      .where(programs: { user_id: current_user.id })
      .find(params[:contract_id])
  end

  def set_delivery_unit
    @delivery_unit = DeliveryUnit.joins(contract: :program)
      .where(programs: { user_id: current_user.id })
      .find(params[:id])

    @contract = @delivery_unit.contract
  end

  def delivery_unit_params
    params.require(:delivery_unit).permit(:unit_serial, :ship_date, :notes)
  end
end
