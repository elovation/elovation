class FlairsController < ApplicationController
  before_action :set_flair, only: [:edit, :destroy, :show, :update]

  def create
    @flair = Flair.new(flair_params)

    if @flair.save
      redirect_to dashboard_path
    else
      render :new
    end
  end

  def destroy
    @flair.destroy if @flair.players.empty?
    redirect_to dashboard_path
  end

  def index
    @flairs = Flair.all
  end

  def edit
  end

  def new
    @flair = Flair.new
  end

  def show
  end

  def update
    if @flair.update_attributes(flair_params)
      redirect_to flair_path(@flair)
    else
      render :edit
    end
  end

  private

  def set_flair
    @flair = Flair.find(params[:id])
  end

  def flair_params
    params.require(:flair).permit(:name, :avatar)
  end
end
