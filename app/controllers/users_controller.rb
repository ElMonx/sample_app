class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :admin_user, only: :destroy

  def new
    unless signed_in?
    	@user = User.new
    else
      redirect_to root_path
    end
  end

  def show
  	@user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def create
    unless signed_in?
      @user = User.new(params[:user])
    	if @user.save
        sign_in @user
        flash[:success] = "Welcome to the Sample App!"
    		redirect_to @user
    	else
    		render 'new'
    	end
    else
      redirect_to root_path
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    user_to_delete = User.find(params[:id])
    if user_to_delete.admin?
      flash[:error] = "You can't delete other admin users."
      redirect_to users_path
    else
      user_to_delete.destroy
      flash[:success] = "User destroyed."
      redirect_to users_path
    end
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
