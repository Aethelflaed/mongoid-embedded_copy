module Mongoid
  module EmbeddedCopy
    extend ActiveSupport::Concern

    class_methods do
      def embeds_copy(name, opts = {})
        klass = opts[:class_name] || name.to_s.camelize
        new_klass = "CopyFor#{self}".gsub('::', '')
        full_klass = [klass, new_klass].join('::')
        EmbeddedCopy.for(klass, opts.merge({:in => self}))
        mongoid_options = Mongoid::Relations::Embedded::One.valid_options +
          Mongoid::Relations::Options::COMMON
        embeds_one name, opts.merge({class_name: full_klass}).slice(*mongoid_options)

        define_method("#{name}_with_copy=") do |value|
          value = full_klass.constantize.new(value) if value.class.name == klass
          self.public_send("#{name}_without_copy=", value)
        end
        alias_method_chain "#{name}=", :copy
      end
    end

    def self.for(klass, opts = {})
      klass = klass.constantize if klass.is_a?(String)
      raise ArgumentError.new('Requires :in options to specify the document in which this one is embedded') if !opts.has_key?(:in)
      raise ArgumentError.new("Can't create an embedded copy of non-mongoid document class #{klass}") if !(klass < Mongoid::Document)
      skipped = Array(opts[:skip]).map{|f| f.to_s}
      skipped.push('deleted_at')

      embed_opts = opts[:in]
      embed_opts = {class_name: embed_opts.to_s, as: embed_opts.to_s.underscore} if embed_opts.is_a?(Class)
      embed_name = embed_opts.delete(:as)
      skipped.push(embed_name).push("#{embed_name}_id")

      document_klass = Class.new do
        include Mongoid::Document
        include Mongoid::EmbeddedCopy.equality_module_for(klass)

        class_attribute :original_class, instance_writer: false
        class_attribute :skipped_attributes, instance_writer: false
        class_attribute :embed_name

        self.original_class = klass
        self.embed_name = embed_name
        self.skipped_attributes = skipped

        def initialize(*attrs)
          if attrs.first.is_a?(original_class)
            attrs = attrs.first.attributes.to_h.dup
            skipped_attributes.each {|n| attrs.delete(n) }
          end
          super(attrs)
        end

        embedded_in embed_name, embed_opts

        klass.fields.each do |name, f|
          next if skipped.include?(name) || name == '_id'
          options = f.options.dup
          options.delete(:klass)
          field name, options
        end

        def load_original
          original_class.find(id)
        end
      end
      klass.const_set("CopyFor#{embed_opts[:class_name].gsub('::', '')}", document_klass)
      klass.send(:include, equality_module_for(klass))
    end

    def self.equality_module_for(klass)
      Module.new do
        extend ActiveSupport::Concern

        included do
          class_attribute :acts_as_method, instance_writer: false
          self.acts_as_method = "acts_as_#{klass.to_s.underscore}"

          define_method(acts_as_method) { true }
        end

        def ==(rhs)
          if rhs.respond_to?(acts_as_method) && rhs.public_send(acts_as_method)
            id == rhs.id
          else
            super
          end
        end
        alias_method :eql?, :==
      end
    end
  end
end

