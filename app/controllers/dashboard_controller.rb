class DashboardController < ApplicationController
  def index
    @user = current_user
    @role_names = @user.role_names
    @can_manage_users = @user.can_manage_users?
    @can_approve = @user.can_approve?
  end
end
