class Pull::CommitDecorator < ApplicationDecorator
  delegate_all

  def short_sha
    sha[0...10]
  end
end
