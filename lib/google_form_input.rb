class GoogleFormInput
  attr_accessor :value
  attr_reader :input_type, :label, :name

  def initialize(input_type, label, name)
    @input_type = input_type
    @label = label
    @name = name
  end

  def to_param
    {@name => @value}
  end
end
