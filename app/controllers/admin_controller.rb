class AdminController < ApplicationController
  before_filter :authenticate_user!
  requires_permission :admin, :only => [:index, :edit_user, :api]
  requires_permission :raid_leader, :only => [:loot, :raids, :logs]

  # TODO : multiple guild support

  # Users management starting page
  def index
    @users = User.all
  end

  def edit_user
    @user = User.find(params[:id])

    if request.post?
      @user.update_attribute(:role, params[:user][:role])
      redirect_to admin_path
    end
  end

  # Raids history page
  def raids
    @raids = current_guild.raids
  end

  # Loot system management
  def loot
    if request.post?
      if params[:file]
        current_guild.loot_uploads.create(:loot_file => params[:file])
        flash[:notice] = "File uploaded"
      else
        flash[:error] = "File missing"
      end
      redirect_to admin_loot_path
    end
  end

  # Log / Events page
  def logs
  end

  # API information page
  def api
    @guild = current_guild

    if @guild.api_key.nil?
      @guild.generate_api_key!
    end
  end

end
