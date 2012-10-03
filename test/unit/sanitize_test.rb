require 'test_helper'

class SanitizeTest < ActiveSupport::TestCase
  test "leave <u> alone" do
    assert_sanitized("<p>Joe was a <u>good</u> boy, but he could be a little <strong>strange</strong>.</p>",
      "<p>Joe was a <u>good</u> boy, but he could be a little <strong>strange</strong>.</p>")
  end
  
  test "remove needless spans" do
    assert_sanitized("<p><span>test<span>2</span></span></p>",
      "<p>test2</p>")
  end

  test "allow tables" do
    assert_sanitized("<table><tr><td>A table!</td></tr></table>", %r{<table>\s*<tr>\s*<td>A table!</td>\s*</tr>\s*</table>})
  end
  
  test "remove non-Vellum classes" do
    assert_sanitized("<p>I have a <span class=\"something vellum-something\">vellum</span> class "+
                    " <i class=\"anotherclass\">and a non-vellum class</i>.</p>",
                    "<p>I have a <span class=\"vellum-something\">vellum</span> class "+
                    " <i>and a non-vellum class</i>.</p>")
  end
  
  test "convert CSS to tags" do
    assert_sanitized("<p style=\"font-weight: bold\">Bold text!</p>", %r{<p>\s*<strong>Bold text!</strong>\s*</p>})
    assert_sanitized("<p style=\"font-style: italic\">Italic text!</p>", %r{<p>\s*<em>Italic text!</em>\s*</p>})
    assert_sanitized("<p style=\"text-decoration: underline\">Underlined text!</p>", %r{<p>\s*<u>Underlined text!</u>\s*</p>})
  end
  
  test "remove non-allowed styles and tags" do
    assert_sanitized("<p class=\"MsoNormal\" style=\"margin-left: 3px;\">Some text</p>", "<p>Some text</p>")
    assert_sanitized("<center>Centered text</center>", "Centered text")
  end
  
  test "convert non-Unix line breaks" do
    assert_sanitized("<p>My text<br />\nis on two lines</p>", "<p>My text<br />\nis on two lines</p>")
    assert_sanitized("<p>My text<br />\r\nis on two lines</p>", "<p>My text<br />\nis on two lines</p>")
    assert_sanitized("<p>My text<br />\ris on two lines</p>", "<p>My text<br />\nis on two lines</p>")
    assert_sanitized("<p>My text<br />\r\nis on<br />\rthree lines</p>", "<p>My text<br />\nis on<br />\nthree lines</p>")
  end

  private
  def assert_sanitized(input, expected)
    output = Sanitize.clean(input, Sanitize::Config::VELLUM)
    case expected
    when String
      assert_equal expected, output
    when Regexp
      assert_match expected, output
    end
  end
end
