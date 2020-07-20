# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Action
  module Items
    class Templates
      include Dry::Monads[:result]

      def call(auth, data)
        result = { auth: auth, data: data }
        Success(result)
      end
    end
  end
end

module Action
  module Items
    class CreateTemplate
      include Dry::Monads[:result]

      def call(auth, data)
        result = { auth: auth, data: data }
        Success(result)
      end
    end
  end
end
