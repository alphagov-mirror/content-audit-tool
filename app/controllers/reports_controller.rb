class ReportsController < BaseController
  before_action :set_default_parameters, only: :show

  def show
    @stats = ReportStats.new(params_to_filter)
    @my_content_items_count = FindContent.users_unaudited_content(current_user.uid).count
  end

private

  def set_default_parameters
    params[:allocated_to] ||= current_user.uid
    params[:audit_status] ||= Audit::ALL
    params[:organisations] ||= [current_user.organisation_content_id]
    params[:primary] = "true" unless params.key?(:primary)
  end
end
