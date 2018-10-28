class ContactsController < ApplicationController
  before_action :set_contact, only: %i(show update destroy)
  wrap_parameters :contact, include: %w(first_name last_name email phone_number star user_id)
  before_action :authenticate_user!

  # GET /contacts
  # GET /contacts.json
  def index
    # @contacts = Contact.all
    # byebug
    @contacts = current_user.contacts
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
  end

  # POST /contacts
  # POST /contacts.json
  def create
    # @contact = Contact.new(contact_params)
    @contact = current_user.contacts.build contact_params

    if @contact.save
      render :show, status: :created, location: @contact
    else
      render json: @contact.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    if @contact.update(contact_params)
      render :show, status: :ok # , location: @contact
    else
      render json: @contact.errors, status: :unprocessable_entity
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy

    head :no_content
  end

  def stars
    @contacts = User.starred_contacts current_user.id
    render :index, status: :ok
  end

  def star
    @contact = Contact.find params[:contact_id]
    # byebug
    if @contact.update(contact_params)
      render :show, status: :ok # , location: @contact
    else
      render json: @contact.errors, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_contact
    @contact = Contact.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def contact_params
    params.require(:contact).permit(:first_name, :last_name, :phone_number, :email, :star, :user_id)
  end
end
