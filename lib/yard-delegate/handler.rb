# frozen_string_literal: true

require 'yard'

module YARD
  module Delegate
    class Handler < YARD::Handlers::Ruby::Base
      handles method_call(:delegate)

      def delegate(*names)
        hash = names.pop
        to   = hash[:to] || hash['to']

        names.each do |name|
          register YARD::CodeObjects::MethodObject.new(namespace, name, scope) { |o|
            o.parameters = [['*args', nil], ['&block', nil]]
            o.source = "def #{name}(*args, &block)\n  #{to}.#{name}(*args, &block)\nend"
            o.signature = "def #{name}(*args, &block)"
            o.docstring = statement.comments.to_s.empty? ? '' : statement.comments
            o.delegate = to
          }
        end
      end

      process do
        begin
          instance_eval(statement.source, __FILE__, __LINE__)
        rescue StandardError
          nil
        end
      end
    end
  end
end
