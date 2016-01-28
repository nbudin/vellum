module DocVersionsHelper
  def diff_sanitized(content1, content2)
    HTMLDiff.diff(sanitize_content(content1) || '', sanitize_content(content2) || '').html_safe
  end
  
  def sanitize_content(content)
    Sanitize.clean(content, Sanitize::Config::VELLUM)
  end
end
