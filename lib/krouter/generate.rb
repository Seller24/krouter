# frozen_string_literal: true

module Krouter
  class Generate
    def call(domain:, actions: [])
      @inflector = Dry::Inflector.new
      actions.map do |action|
        chunks = split_class(action)
        base = domain + '.' + chunks.join('.')
        from = base + suffix(chunks.last)
        to = base + '-receive'

        [from, { action: action, to: to }]
      end.to_h
    end

    private

    def split_class(class_name)
      class_name.class.to_s.split('::').drop(1).map do |chunk|
        @inflector.underscore(chunk)
      end
    end

    def suffix(class_name)
      create_names = %w[create build]
      is_create = create_names.any? { |name| class_name.include?(name) }
      is_create ? '-create' : '-get'
    end
  end
end
