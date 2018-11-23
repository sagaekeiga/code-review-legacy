class Reviewers::SendMailsController < Reviewers::BaseController
  skip_before_action :check_reviewer_status, only: %i(create)

  def create
    @send_mail = current_reviewer.send_mails.new(send_mail_params)

    if @send_mail.save
      redirect_to :reviewers_pending, success: 'メールアドレスを送信しました'
    else
      redirect_to :reviewers_pending, danger: '送信に失敗しました'
    end
  end

  private

  def send_mail_params
    params.require(:send_mail).permit(:email)
  end
end
