module ApplicationHelper
  #
  # デフォルトメタタグ設定
  #
  def default_meta_tags
    {
      site: Settings.meta.site.name,
      reverse: true,
      title: Settings.meta.site.name,
      description: Settings.meta.site.page_description,
      keywords: Settings.meta.site.page_keywords,
      canonical: request.original_url,
      og: {
        title: :title,
        description: Settings.og.page_description,
        type: Settings.og.type,
        url: request.original_url,
        # image: image_url(Settings.site.meta.ogp.image_path),
        site_name: Settings.meta.site.name,
        locale: 'ja_JP'
      }
    }
  end
end
