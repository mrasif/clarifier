class Api::ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate

  def logged_in?
    !!current_user
  end

  def current_user
    if jwt_auth_present?
      @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id] == decoded_data["user_id"]
    end
  end

  def authenticate
    render json: {error: "unauthorized access"}, status: 401 unless logged_in?
  end

  def render_json_api(resource, options = {})
    options[:adapter] ||= :json_api
    options[:namespace] ||= Api
    options[:key_transform] ||= :camel_lower
    options[:serialization_context] ||= ActiveModelSerializers::SerializationContext.new(request)
    ActiveModelSerializers::SerializableResource.new(resource, options)
  end

  def render_success(status, resource, options = {})
    options[:meta] ||= {}
    render json: render_json_api(resource, options).as_json, status: status
  end

  def render_error(status, errors = [], meta = {})
    render json: { errors: errors, meta: meta }, status: status
  end

  private

  def decoded_data
    token = request.env["HTTP_AUTHORIZATION"].scan(/Bearer(.*)$/).flatten.last.strip
    JwtAuth.decode(token)
  end

  def jwt_auth_present?
    !!request.env.fetch("HTTP_AUTHORIZATION", "").scan(/Bearer/).flatten.first
  end
end
