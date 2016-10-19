# frozen_string_literal: true
module V1
  class ChartsController < ApplicationController
    before_action :set_chart, only: [:show, :update, :destroy]

    def index
      @charts = Chart.fetch_all(chart_type_filter)
      render json: @charts, each_serializer: ChartArraySerializer, root: false
    end

    def show
      render json: @chart, serializer: ChartSerializer, root: false, meta: chart_meta(@chart)
    end

    def update
      if @chart.update(chart_params)
        render json: @chart, status: 200, serializer: ChartSerializer, root: false, meta: chart_meta(@chart)
      else
        render json: { success: false, message: @chart.errors }, status: 422
      end
    end

    def create
      @chart = Chart.new(chart_params_for_create)
      if @chart.save
        render json: @chart, status: 201, serializer: ChartSerializer, root: false, meta: chart_meta(@chart)
      else
        render json: { success: false, message: @chart.errors }, status: 422
      end
    end

    def destroy
      @chart.destroy
      begin
        render json: { message: 'Chart deleted' }, status: 200
      rescue ActiveRecord::RecordNotDestroyed
        return render json: @chart.erors, message: 'Chart could not be deleted', status: 422
      end
    end

    def docs
      @docs = YAML.load(File.read('lib/files/swagger.yml')).to_json
      render json: @docs
    end

    def info
      @service = ServiceSetting.save_gateway_settings(params)
      if @service
        @docs = Oj.load(File.read("lib/files/service_#{ENV['RAILS_ENV']}.json"))
        render json: @docs
      else
        render json: { success: false, message: 'Missing url and token params' }, status: 422
      end
    end

    private

      def set_chart
        @chart = Chart.by_id_or_slug(params[:id])
        record_not_found if @chart.blank?
      end

      def chart_type_filter
        params.permit(:status, :published, :verified, :app, :template, :dataset, :default, :chart)
      end

      def chart_meta(chart)
        { status: chart.try(:status_txt),
          published: chart.try(:published),
          verified: chart.try(:verified),
          updated_at: chart.try(:updated_at),
          created_at: chart.try(:created_at) }
      end

      def chart_params
        params.require(:chart).permit(:name, :slug, :description, :source, :source_url, :authors, :query_url, :chart_config,
                                      :status, :published, :verified, :layer_id, :dataset_id,
                                      :template, :default, application: [])
      end

      def chart_params_for_create
        chart_params[:status].present? ? chart_params : chart_params.merge(status: 1)
      end
  end
end
