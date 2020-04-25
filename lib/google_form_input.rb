class GoogleFormInput
  attr_reader :input_type, :label, :name, :value

  def initialize(input_type, label, name)
    @input_type = input_type
    @label = label
    @name = name
  end

  def value=(value)
    @value = value
  end

  def to_param
    {@name => @value}
  end
end
