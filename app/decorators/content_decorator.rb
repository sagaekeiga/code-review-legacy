class ContentDecorator < ApplicationDecorator
  delegate_all

  def breadcrumbs
    (repo.full_name + '/' + path).gsub!('/', ' / ')
  end

  def btn_by_status
    case status
    when 'hidden'
      'btn-outline-primary'
    when 'showing'
      'btn-outline-danger'
    end
  end

  def text_by_status
    case status
    when 'hidden'
      '公開する'
    when 'showing'
      '非公開にする'
    end
  end

  def decode_by_base64
    Base64.decode64(content).encode('Shift_JIS', 'UTF-8')
  end
end
