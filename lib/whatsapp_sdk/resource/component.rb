# frozen_string_literal: true
# typed: strict

module WhatsappSdk
  module Resource
    class Component
      extend T::Sig

      class InvalidField < StandardError
        extend T::Sig

        sig { returns(Symbol) }
        attr_reader :field

        sig { returns(String) }
        attr_reader :message

        sig { params(field: Symbol, message: String).void }
        def initialize(field, message)
          @field = field
          @message = message
          super(message)
        end
      end

      class Type < T::Enum
        extend T::Sig

        enums do
          Header = new("header")
          Body = new("body")
          Button = new("button")
        end
      end

      class Subtype < T::Enum
        extend T::Sig

        enums do
          QuickReply = new("quick_reply")
          Url = new("url")
        end
      end

      # Returns the Component type.
      #
      # @returns type [String]. Supported Options are header, body and button.
      sig { returns(Type) }
      attr_accessor :type

      # Returns the parameters of the component. For button type, it's required.
      #
      # @returns parameter [Array<ButtonParameter, ParameterObject>] .
      sig { returns(T::Array[T.any(ButtonParameter, ParameterObject)]) }
      attr_accessor :parameters

      # Returns the Type of button to create. Required when type=button. Not used for the other types.
      # Supported Options
      # quick_reply: Refers to a previously created quick reply button
      # that allows for the customer to return a predefined message.
      # url: Refers to a previously created button that allows the customer to visit the URL generated by
      # appending the text parameter to the predefined prefix URL in the template.
      #
      # @returns subtype [String]. Valid options are quick_reply and url.
      sig { returns(T.nilable(WhatsappSdk::Resource::Component::Subtype)) }
      attr_accessor :sub_type

      # Required when type=button. Not used for the other types.
      # Position index of the button. You can have up to 3 buttons using index values of 0 to 2.
      #
      # @returns index [Integer].
      sig { returns(T.nilable(Integer)) }
      attr_accessor :index

      sig { params(parameter: T.any(ButtonParameter, ParameterObject)).void }
      def add_parameter(parameter)
        @parameters << parameter
      end

      sig do
        params(
          type: Type, parameters: T::Array[T.any(ButtonParameter, ParameterObject)],
          sub_type: T.nilable(WhatsappSdk::Resource::Component::Subtype), index: T.nilable(Integer)
        ).void
      end
      def initialize(type:, parameters: [], sub_type: nil, index: nil)
        @parameters = parameters
        @type = type
        @sub_type = sub_type
        @index = index.nil? && type == Type::Button ? 0 : index
        validate_fields
      end

      sig { returns(T::Hash[T.untyped, T.untyped]) }
      def to_json
        json = {
          type: type.serialize,
          parameters: parameters.map(&:to_json)
        }
        json[:sub_type] = sub_type&.serialize if sub_type
        json[:index] = index if index
        json
      end

      private

      sig { void }
      def validate_fields
        return if type == Type::Button

        raise InvalidField.new(:sub_type, 'sub_type is not required when type is not button') if sub_type

        raise InvalidField.new(:index, 'index is not required when type is not button') if index
      end
    end
  end
end
