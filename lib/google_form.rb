require 'curb'
require 'nokogiri'

require_relative 'google_form_input'

class GoogleForm
  BASE_URL = 'https://docs.google.com/forms'

  def initialize(google_form_url_or_id)
    @id = if is_an_url?(google_form_url_or_id)
            form_id_from_url(google_form_url_or_id)
          else
            google_form_url_or_id
          end

    define_input_methods
  end

  def post(data = {})
    params_for_curb = params_from_data(data).merge(params_from_inputs.compact)

    Curl.post(form_response_url, params_for_curb)
  end

  def inputs
    input_nodes = nokogiri_doc
      .css('form input')
      .reject { |i| i.attribute('aria-label').nil?  }

    @inputs ||= input_nodes.map do |i|
      GoogleFormInput.new(
        i.attribute('type').value,
        i.attribute('aria-label').value,
        i.attribute('name').value
      )
    end
  end

  def params_from_data(data)
    data.map { |k, v| [self.send(k).name, v] }.to_h
  end

  def params_from_inputs
    inputs.map(&:to_param).reduce({}, :merge)
  end

  def form_body
    @form_body ||= Curl.get(view_form_url).body
  end

  def nokogiri_doc
    @nokogiri_doc ||= Nokogiri::HTML(form_body)
  end

  def form_response_url
    "#{BASE_URL}/u/0/d/e/#{@id}/formResponse"
  end

  def view_form_url
    "#{BASE_URL}/d/e/#{@id}/viewform"
  end

  def to_s
    inspect
  end

  def inspect
    hidden_variables = %i[@inputs @form_body @nokogiri_doc]

    variables_to_string =
      (self.instance_variables - hidden_variables).map do |variable|
        "#{variable}=\\\"#{instance_variable_get(variable)}\\\""
      end

    "#<#{self.class}:#{object_id} #{variables_to_string.join(', ')}>"
  end

  private

  def define_input_methods
    inputs.each do |input|
      self.class.send(:define_method, input.label.to_sym) do
        input
      end

      self.class.send(:define_method, "#{input.label.to_sym}=") do |*args|
        input.value = args.first
      end
    end
  end

  def form_id_from_url(form_url)
    response = Curl.get(form_url)

    if response.response_code == 302
      return form_id_from_viewform_url(response.redirect_url)
    end

    @form_body ||= response.body
    form_id_from_viewform_url(form_url)
  end

  def form_id_from_viewform_url(url)
    url.match(/docs.google.com\/forms\/d\/e\/(.*)\/viewform/)[1]
  end

  def is_an_url?(string)
    string =~ /\A#{URI::regexp(['http', 'https'])}\z/
  end
end
