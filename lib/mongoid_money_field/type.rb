class MoneyType
    attr_accessor :options

    def initialize(options = {})
      @options = {
          fixed_currency: nil,
          default: nil,
          required: false,
          default_currency: nil
      }.merge(options)
    end

    # Get the object as it was stored in the database, and instantiate
    # this custom class from it.
    def demongoize(object)
      if object.is_a?(Hash)
        object.stringify_keys!
        if object.has_key?('cents')
          if @options[:fixed_currency]
            ::Money.new(object['cents'], @options[:fixed_currency])
          else
            if object.has_key?('currency_iso')
              ::Money.new(object['cents'], object['currency_iso'])
            else
              ::Money.new(object['cents'], @options[:default_currency])
            end
          end
        else
          nil
        end
      elsif object.is_a?(Fixnum) || object.is_a?(Float)
        if @options[:fixed_currency]
          ::Money.new(object, @options[:fixed_currency])
        else
          ::Money.new(object, @options[:default_currency])
        end
      else
        nil
      end
    end

    # Takes any possible object and converts it to how it would be
    # stored in the database.
    def mongoize(object)
      unless @options[:default_currency].nil?
        old_default = Money.default_currency
        Money.default_currency = Money::Currency.new(@options[:default_currency])
      end

      ret = case
        when object.is_a?(Money) then object.mongoize
        when object.is_a?(Hash) then
          object.symbolize_keys! if object.respond_to?(:symbolize_keys!)
          ::Money.new(object[:cents], object[:currency_iso]).mongoize
        when object.blank? then
          if !@options[:default].nil?
            @options[:default].to_money.mongoize
          else
            nil
          end
        when object.respond_to?(:to_money) then
          object.to_money.mongoize
        else object
      end

      unless @options[:default_currency].nil?
        Money.default_currency = old_default
      end
      
      if !ret.nil? && @options[:fixed_currency]
        ret[:currency_iso] = @options[:fixed_currency]
      end

      ret
    end

    # Converts the object that was supplied to a criteria and converts it
    # into a database friendly form.
    def evolve(object)
      case object
        when Money then object.mongoize
        else object
      end
    end
end
