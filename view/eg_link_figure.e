note
	description: "Object is a view for an EG_LINK"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	EG_LINK_FIGURE

inherit
	EG_FIGURE
		redefine
			initialize,
			model,
			xml_element,
			xml_node_name,
			set_with_xml_element,
			recycle,
			process
		end

feature {NONE} -- Initialization

	initialize
			-- Initialize `Current' (synchronize with `model').
		do
			Precursor {EG_FIGURE}
			model.is_directed_change_actions.extend (agent on_is_directed_change)
		end

feature -- Status report

	is_reflexive: BOOLEAN
			-- Is `Current' reflexive?
		do
			Result := source = target
		end


feature -- Access

	source: EG_LINKABLE_FIGURE
			-- source of `Current'.

	target: like source
			-- target of `Current'.

	model: EG_LINK
			-- The model for `Current'.

	neighbor_of (a_item: like source): like source
			-- Neighbor of `a_item'.
		require
			a_item_not_void: a_item /= Void
		do
			if a_item = source then
				Result := target
			else
				Result := source
			end
		ensure
			result_definition: Result = (if a_item = source then target else source end)
		end

	xml_element (node: like xml_element): XML_ELEMENT
			-- Xml node representing `Current's state.
		local
			l_model: like model
		do
			l_model := model
			Result := Precursor {EG_FIGURE} (node)
			if attached l_model.source.link_name as l_link_name then
				Result.add_attribute (once "SOURCE", xml_namespace, l_link_name)
			end
			if attached l_model.target.link_name as l_link_name then
				Result.add_attribute (once "TARGET", xml_namespace, l_link_name)
			end
			Result.put_last (Xml_routines.xml_node (Result, is_directed_string, boolean_representation (l_model.is_directed)))
		end

	set_with_xml_element (node: like xml_element)
			-- Retrive state from `node'.
		do
			node.forth
			node.forth
			Precursor {EG_FIGURE} (node)
			model.set_is_directed (xml_routines.xml_boolean (node, is_directed_string))
		end

	is_directed_string: STRING = "IS_DIRECTED"

	xml_node_name: STRING
			-- Name of the node returned by `xml_element'.
		do
			Result := once "EG_LINK_FIGURE"
		end

feature -- Element change

	recycle
			-- Free `Current's resources.
		do
			Precursor {EG_FIGURE}
			model.is_directed_change_actions.extend (agent on_is_directed_change)
		end

feature -- Visitor

	process (a_visitor: EG_FIGURE_VISITOR)
			-- Visitor feature.
		do
			a_visitor.process_link_figure (Current)
		end

feature {NONE} -- Implementation

	on_is_directed_change
			-- `model'.`is_directed' changed
		deferred
		end

invariant
	source_not_void: source /= Void
	target_not_void: target /= Void

note
	copyright:	"Copyright (c) 1984-2014, Eiffel Software and others"
	license:	"Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"




end -- class EG_LINK_FIGURE

