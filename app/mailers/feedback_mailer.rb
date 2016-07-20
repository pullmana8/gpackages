class FeedbackMailer < ApplicationMailer
  def feedback_email(feedback, contact)
    @feedback = feedback
    @contact = contact

    mail(to: KKULEOMI_FEEDBACK_RECIPIENT, subject: 'Feedback')
  end
end
