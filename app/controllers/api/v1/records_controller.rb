class Api::V1::RecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_record, only: %i[show]

  def show
    render json: {
             status: 'SUCCESS',
             message: 'Loaded the record',
             data: @record,
           }
  end

  def set_record
    @record =
      current_user.records.find_by(job_id: current_user.job_id) ||
        current_user.records.create!(job_id: current_user.job_id)
  end
end
