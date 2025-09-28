# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  def edit
    if turbo_frame_request?
      # Turbo Frameならフォーム表示
      super
    else
      # 通常遷移ならマイページへ
      redirect_to mypage_user_path, alert: "都合により、マイページを再読み込みしました。<br>ユーザー編集の場合は再度「編集」ボタンを押してください。"
    end
  end

  # PUT /resource
  # We need to use a copy of the resource because we don't want to change
  # the current user in place.
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?

      # claudeで変更（明示的なTurbo化）
      # respond_with resource, location: after_update_path_for(resource)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to after_update_path_for(resource) }
      end
    else
      clean_up_passwords resource
      set_minimum_password_length

      # claudeで変更（明示的なTurbo化）
      # respond_with resource
      respond_to do |format|
        format.turbo_stream { render :update, status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
    current_user.reload
  end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    root_path
  end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    root_path
  end

  protected
  # パスワードなしでユーザー情報を更新
  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  # 編集後のリダイレクト先を指定するメソッド
  def after_update_path_for(resource)
    mypage_user_path(resource)
  end

  private

  def set_flash_message_for_update(resource, prev_unconfirmed_email)
    return unless is_flashing_format?

    flash_key = if update_needs_confirmation?(resource, prev_unconfirmed_email)
      :update_needs_confirmation
    elsif sign_in_after_change_password?
      :updated
    else
      :updated_but_not_signed_in
    end
    # set_flash_message :notice, flash_key
    flash.now[:notice] = I18n.t("devise.registrations.#{flash_key}")
  end
end
