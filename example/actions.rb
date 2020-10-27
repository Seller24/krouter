# frozen_string_literal: true

module Action
  module Items
    class Templates
      def call(page: 0)
        'Page number: ' + page 
      end
    end
  end
end

module Action
  module Items
    class CreateTemplate
      def call(name: 'Some Name')
        'Created template: ' + name
      end
    end
  end
end
