note
	description: "Objects that is a view for an EG_ITEM."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	EG_FIGURE

inherit
	EV_MODEL_MOVE_HANDLE
		undefine
			new_filled_list
		redefine
			world,
			default_create
		end

	EG_XML_STORABLE
		undefine
			default_create
		end

feature {NONE} -- Initialization

	default_create
			-- Create an EG_FIGURE.
		do
			is_center_valid := True
			create name_label
			Precursor {EV_MODEL_MOVE_HANDLE}
			extend (name_label)
		end

	initialize
			-- Initialize `Current' (synchronize with model).
		do
			if attached model.name as l_name then
				set_name_label_text (l_name)
			else
				name_label.set_text (once "")
				name_label.hide
			end
			model.name_change_actions.extend (agent on_name_change)
		end

feature -- Constant

	is_selected_string: STRING = "IS_SELECTED"
			-- Xml mark representing `is_selected'.

	is_label_shown_string: STRING = "IS_LABEL_SHOWN"
			-- Xml mark representing `is_label_shown'.

	name_string: STRING = "NAME"
			-- Xml mark representing `model's name.

feature -- Access

	model: EG_ITEM
			-- The model for `Current'.

	world: detachable EG_FIGURE_WORLD
			-- The world `Current' is part of.
		do
			if attached {like world} Precursor as l_result then
				Result := l_result
			end
		end

	xml_element (a_node: like xml_element): XML_ELEMENT
			-- <Precursor>
		local
			l_xml_routines: like xml_routines
		do
			l_xml_routines := xml_routines
			if attached model.name as l_name then
				a_node.add_attribute (name_string, xml_namespace, l_name)
			end
			a_node.put_last (l_xml_routines.xml_node (a_node, is_selected_string, boolean_representation (is_selected)))
			a_node.put_last (l_xml_routines.xml_node (a_node, is_label_shown_string, boolean_representation (is_label_shown)))
			Result := a_node
		end

	set_with_xml_element (a_node: like xml_element)
			-- <Precursor>
		local
			l_xml_routines: like xml_routines
		do
			l_xml_routines := xml_routines
			if attached a_node.attribute_by_name (name_string) as l_attribute then
				model.set_name (l_attribute.value)
				a_node.forth
			end
			set_is_selected (l_xml_routines.xml_boolean (a_node, is_selected_string))
			if l_xml_routines.xml_boolean (a_node, is_label_shown_string) then
				if not is_label_shown then
					show_label
				end
			else
				if is_label_shown then
					hide_label
				end
			end
		end

	xml_node_name: STRING
			-- <Precursor>
		do
			Result := once "EG_FIGURE"
		end

feature -- Status report

	is_selected: BOOLEAN
			-- Is `Current' selected?

	is_storable: BOOLEAN
			-- Does `Current' need to be persistently stored?
			-- True by default.
		do
			Result := True
		end

	is_label_shown: BOOLEAN
			-- Is label shown?
		do
			Result := name_label.is_show_requested
		end

	is_update_required: BOOLEAN
			-- Is an update required?

feature -- Element change

	recycle
			-- Free resources of `Current' such that GC can collect it.
			-- Leave it in an unstable state.
		do
			model.name_change_actions.prune_all (agent on_name_change)
		end

feature -- Status setting

	enable_selected
			-- Enable select.
		do
			set_is_selected (True)
		ensure
			selected: is_selected
		end

	disable_selected
			-- Disable select.
		do
			set_is_selected (False)
		ensure
			deselected: not is_selected
		end

	show_label
			-- Show name label.
		require
			not_shown: not is_label_shown
		do
			name_label.show
			request_update
		ensure
			is_label_shown: is_label_shown
		end

	hide_label
			-- Hide name label.
		require
			shown: is_label_shown
		do
			name_label.hide
			request_update
		ensure
			not_is_lable_shown: not is_label_shown
		end

	request_update
			-- Set `is_update_required' to True.
		do
			is_update_required := True
		ensure
			set: is_update_required
		end

feature -- Visitor

	process (v: EG_FIGURE_VISITOR)
			-- <Precursor>
		do
			v.process_figure (Current)
		end

feature {EG_FIGURE, EG_FIGURE_WORLD} -- Update

	update
			-- Some properties may have changed.
		deferred
		ensure
			not_is_update_required: not is_update_required
		end

feature {NONE} -- Implementation

	set_is_selected (a_is_selected: like is_selected)
			-- Set `is_selected' to `a_is_selected'.
		deferred
		ensure
			is_selected_assigned: is_selected = a_is_selected
		end

	name_label: EV_MODEL_TEXT
			-- The label for the name.

	on_name_change
			-- Name was changed in the model.
		do
			if attached model.name as l_name then
				if name_label.text.is_empty and not is_label_shown then
					name_label.show
				end
				set_name_label_text (l_name)
			else
				name_label.hide
			end
			request_update
		end

	set_name_label_text (a_text: STRING)
			-- Set `name_label'.`text' to `a_text'.
			-- | Redefine in subclass if you want make changes to the text.
		require
			a_text_not_void: a_text /= Void
			a_text_equal_model_text: attached model.name as l_name and then l_name = a_text
		do
			name_label.set_text (a_text)
		end

invariant
	name_label_not_void: name_label /= Void
	model_not_void: model /= Void

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




end -- class EG_FIGURE

