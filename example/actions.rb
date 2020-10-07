# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Action
  module Items
    class Templates
      include Dry::Monads[:result]

      def call(value:)
        Success(value)
      end
    end
  end
end

module Action
  module Items
    class CreateTemplate
      include Dry::Monads[:result]

      def call(value:)
        Success(value)
      end
    end
  end
end
