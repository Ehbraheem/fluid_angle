class FoosController < ApplicationController
  before_action :set_foo, only: %i(show update destroy)
  wrap_parameters :foo, include: ['name']

  # GET /foos
  def index
    @foos = Foo.all

    # render json: @foos
  end

  # GET /foos/1
  def show
    # render json: @foo
  end

  # POST /foos
  def create
    @foo = Foo.new(foo_params)

    if @foo.save
      # render json: @foo, status: :created, location: @foo
      # byebug
      render :show, status: :created, location: @foo
    else
      render json: @foo.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /foos/1
  def update
    if @foo.update(foo_params)
      render :show, status: :ok
    else
      render json: @foo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /foos/1
  def destroy
    @foo.destroy

    head :no_content
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_foo
    @foo = Foo.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def foo_params
    params.require(:foo).permit(:name)
  end
end
