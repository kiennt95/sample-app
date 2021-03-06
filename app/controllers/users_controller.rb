class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(new create show)
  before_action :find_user, except: %i(new create index)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate page: params[:page]
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if user.save
      user.send_activation_email
      flash[:info] = t "user.check"
      redirect_to root_url
    else
      render :new
    end
  end

  def show
    active_relationships = current_user.active_relationships
    @microposts = user.microposts.order_desc.paginate page: params[:page]

    @relationship =
      if current_user.following? user
        active_relationships.find_by followed_id: user.id
      else
        active_relationships.build
      end
  end

  def edit; end

  def update
    if user.update_attributes user_params
      flash[:success] = t "edit.success"
      redirect_to user
    else
      render :edit
    end
  end

  def destroy
    user.destroy
    flash[:success] = t "user.destroy"
    redirect_to users_url
  end

  private

  attr_reader :user

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def correct_user
    redirect_to root_url unless user.current_user? current_user
  end

  def find_user
    @user = User.find_by id: params[:id]

    return if user
    flash[:danger] = t "user.error"
    redirect_to root_url
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end
end
