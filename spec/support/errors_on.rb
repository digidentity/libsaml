module ::ActiveModel::Validations
  # Extension to enhance `should have` on AR Model instances.  Calls
  # model.valid? in order to prepare the object's errors object. Accepts
  # a :context option to specify the validation context.
  #
  # You can also use this to specify the content of the error messages.
  #
  # @example
  #
  #     model.should have(:no).errors_on(:attribute)
  #     model.should have(1).error_on(:attribute)
  #     model.should have(n).errors_on(:attribute)
  #     model.should have(n).errors_on(:attribute, :context => :create)
  #
  #     model.errors_on(:attribute).should include("can't be blank")
  def errors_on(attribute, options = {})
    valid_args = [options[:context]].compact
    self.valid?(*valid_args)

    [self.errors[attribute]].flatten.compact
  end

  alias :error_on :errors_on
end
