module ApplicationHelper
  #
  # デフォルトメタタグ設定
  #
  def default_meta_tags
    {
      site: Settings.site.name,
      reverse: true,
      title: Settings.site.page_title,
      description: Settings.site.page_description,
      keywords: Settings.site.page_keywords,
      canonical: request.original_url,
      og: {
        title: :title,
        description: Settings.site.page_description,
        type: Settings.site.meta.ogp.type,
        url: request.original_url,
        image: image_url(Settings.site.meta.ogp.image_path),
        site_name: Settings.site.name,
        locale: 'ja_JP'
      }
    }
  end

  def date_format(datetime)
    time_ago_in_words(datetime) + '前' if datetime
  end
end
