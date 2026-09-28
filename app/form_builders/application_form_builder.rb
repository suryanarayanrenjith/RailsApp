# Flags invalid fields for assistive technology: fields with errors get
# aria-invalid and point at their #error_message via aria-describedby
# (alongside any description, such as a hint, they already reference).
class ApplicationFormBuilder < ActionView::Helpers::FormBuilder
  %i[ text_field email_field password_field search_field text_area ].each do |field_helper|
    define_method(field_helper) do |attribute, options = {}|
      super(attribute, with_error_description(attribute, options))
    end
  end

  def error_message(attribute)
    messages = object&.errors&.full_messages_for(attribute)
    return if messages.blank?

    @template.tag.p messages.to_sentence, id: error_id(attribute), class: "field-error"
  end

  private
    def with_error_description(attribute, options)
      return options unless object&.errors&.include?(attribute)

      aria = options.fetch(:aria, {})
      options.merge aria: aria.merge(invalid: true, describedby: [ aria[:describedby], error_id(attribute) ].compact.join(" "))
    end

    def error_id(attribute)
      "#{object_name}_#{attribute}_error"
    end
end
