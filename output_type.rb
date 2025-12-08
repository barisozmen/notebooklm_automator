# Single source of truth for output types
class OutputType
  attr_reader :key, :label

  def initialize(key, label)
    @key = key
    @label = label
  end

  ALL = [
    new(:mindmap, "Mind Map"),
    new(:flashcards, "Flashcards"),
    new(:slides, "Slide Deck"),
    new(:interactive_chart, "Infographic")
  ].freeze

  def self.find(key)
    ALL.find { |type| type.key == key } || raise("Unknown output type: #{key}")
  end

  def self.all_keys
    ALL.map(&:key)
  end

  def self.for_ui
    ALL.map { |t| { name: t.label, value: t.key } }
  end

  def self.button_label(key)
    find(key).label
  end
end
