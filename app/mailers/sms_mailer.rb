class SmsMailer < ApplicationMailer
  def sms_notification
    @phone_number = params[:phone_number]
    @message = params[:message]
    mail(to: "#{@phone_number}@sms.local", subject: "SMS to #{@phone_number}")
  end
end
