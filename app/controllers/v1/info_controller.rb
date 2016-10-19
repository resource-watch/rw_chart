# frozen_string_literal: true
module V1
  class InfoController < ApplicationController
    def docs
      @docs = YAML.load(File.read('lib/files/swagger.yml')).to_json
      render json: @docs
    end

    def info
      @docs = Oj.load(File.read("lib/files/service_#{ENV['RAILS_ENV']}.json"))
      render json: @docs
    end

    def ping
      render json: { success: true, message: 'RW Tags online' }, status: 200
    end
  end
end
