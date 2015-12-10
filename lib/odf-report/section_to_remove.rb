module ODFReport

  class SectionToRemove < Section
    def replace!(doc, row = nil)
      return unless @section_node = find_section_node(doc)
      @section_node.remove
    end
  end
end